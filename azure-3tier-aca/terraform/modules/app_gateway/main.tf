# Public IP for Application Gateway
resource "azurerm_public_ip" "agw" {
  name                = "pip-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Application Gateway on HTTP ONLY (for IP access, no domain/SSL)
resource "azurerm_application_gateway" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "agw-ip-config"
    subnet_id = var.subnet_id
  }

  # HTTP only
  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "agw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.agw.id
  }

  # Backend pools - internal FQDNs of Container Apps
  backend_address_pool {
    name  = "frontend-pool"
    fqdns = [var.frontend_fqdn]
  }

  backend_address_pool {
    name  = "backend-pool"
    fqdns = [var.backend_fqdn]
  }

  # Probes (HTTP)
  probe {
    name                                      = "frontend-probe"
    protocol                                  = "Http"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 60
    unhealthy_threshold                       = 5
    pick_host_name_from_backend_http_settings = true
    port                                      = 80
    match { status_code = ["200-499"] }
  }

  probe {
    name                                      = "backend-probe"
    protocol                                  = "Http"
    path                                      = "/actuator/health"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    port                                      = 80
    match { status_code = ["200-299"] }
  }

  # HTTP settings to Container Apps (HTTP)
  backend_http_settings {
    name                                = "frontend-http-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    pick_host_name_from_backend_address = false
    host_name                           = var.frontend_fqdn
    probe_name                          = "frontend-probe"
  }

  backend_http_settings {
    name                                = "backend-http-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = "backend-probe"
  }

  # Single HTTP listener
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "agw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  # URL rewrite for API paths
  rewrite_rule_set {
    name = "api-rewrite"
    
    rewrite_rule {
      name          = "add-api-prefix"
      rule_sequence = 100
      
      condition {
        variable    = "var_uri_path"
        pattern     = "^/api/(.*)$"
        ignore_case = true
      }
      
      url {
        path         = "/api/{var_uri_path_1}"
        reroute      = false
      }
    }
  }

  # Path map on HTTP
  url_path_map {
    name                               = "http-path-map"
    default_backend_address_pool_name  = "frontend-pool"
    default_backend_http_settings_name = "frontend-http-settings"

    path_rule {
      name                       = "api-rule"
      paths                      = ["/api/*", "/actuator/*"]
      backend_address_pool_name  = "backend-pool"
      backend_http_settings_name = "backend-http-settings"
      rewrite_rule_set_name      = "api-rewrite"
    }
  }

  # Routing rule on HTTP
  request_routing_rule {
    name               = "http-routing-rule"
    rule_type          = "PathBasedRouting"
    http_listener_name = "http-listener"
    url_path_map_name  = "http-path-map"
    priority           = 100
  }

  # SSL policy (even for HTTP-only, Azure requires this)
  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  # WAF configuration (Detection mode)
  waf_configuration {
    enabled          = true
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"

    disabled_rule_group {
      rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
      rules           = [920300, 920330]
    }
  }
}
