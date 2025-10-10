# Public IP for Application Gateway
resource "azurerm_public_ip" "agw" {
  name                = "pip-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Application Gateway with HTTPS termination and HTTP backend
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

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "agw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.agw.id
  }

  # SSL certificate for HTTPS termination - using Azure managed certificate
  ssl_certificate {
    name = "agw-ssl-cert"
    data = filebase64("${path.module}/yousef-burgerbuilder.pfx")
    password = "YousefBurgerBuilder2024!"
  }

  # Backend pools - use internal FQDNs
  backend_address_pool {
    name = "frontend-pool"
    fqdns = [var.frontend_fqdn]
  }

  backend_address_pool {
    name = "backend-pool"
    fqdns = [var.backend_fqdn]
  }

  # Health probes - use HTTP to Container Apps internal endpoints
  probe {
    name                                      = "frontend-probe"
    protocol                                  = "Http"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 60
    unhealthy_threshold                       = 5
    pick_host_name_from_backend_http_settings = true
    port                                      = 80
    
    match {
      status_code = ["200-499"]
    }
  }

  probe {
    name                                      = "backend-probe" 
    protocol                                  = "Http"
    path                                      = "/api/health"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    port                                      = 80
    
    match {
      status_code = ["200-299"]
    }
  }

  # HTTP settings - use HTTP to backend Container Apps (HTTPS termination at App Gateway)
  backend_http_settings {
    name                                = "frontend-http-settings"
    cookie_based_affinity               = "Disabled"
    path                                = "/"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    pick_host_name_from_backend_address = false
    host_name                           = var.frontend_fqdn
    probe_name                          = "frontend-probe"
    trusted_root_certificate_names      = []
  }

  backend_http_settings {
    name                                = "backend-http-settings"
    cookie_based_affinity               = "Disabled"
    path                                = "/"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = "backend-probe"
    trusted_root_certificate_names      = []
  }

  # HTTP listeners
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "agw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "agw-frontend-ip"
    frontend_port_name             = "https-port"
    protocol                       = "Https"
    ssl_certificate_name           = "agw-ssl-cert"
  }

  # HTTP to HTTPS redirect
  redirect_configuration {
    name                 = "http-to-https-redirect"
    redirect_type        = "Permanent"
    target_listener_name = "https-listener"
    include_path         = true
    include_query_string = true
  }

  # URL path map for HTTPS traffic
  url_path_map {
    name                               = "https-path-map"
    default_backend_address_pool_name  = "frontend-pool"
    default_backend_http_settings_name = "frontend-http-settings"

    path_rule {
      name                       = "api-rule"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "backend-pool"
      backend_http_settings_name = "backend-http-settings"
    }
  }

  # Request routing rules
  request_routing_rule {
    name                        = "http-redirect-rule"
    rule_type                   = "Basic"
    http_listener_name          = "http-listener"
    redirect_configuration_name = "http-to-https-redirect"
    priority                    = 100
  }

  request_routing_rule {
    name                  = "https-routing-rule"
    rule_type             = "PathBasedRouting"
    http_listener_name    = "https-listener"
    url_path_map_name     = "https-path-map"
    priority              = 200
  }

  # SSL policy
  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101S"
  }

  # WAF configuration
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