resource "azurerm_container_app" "main" {
  name                         = "ca-${var.name}"
  container_app_environment_id = var.container_apps_env_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = var.tags

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.name
      image  = var.container_image
      cpu    = var.cpu_requests
      memory = var.memory_requests

      dynamic "env" {
        for_each = var.environment_variables
        content {
          name        = env.value.name
          value       = env.value.value
          secret_name = env.value.secret_name
        }
      }
    }
  }

  dynamic "secret" {
    for_each = var.secrets
    content {
      name  = secret.value.name
      value = secret.value.value
    }
  }

  dynamic "ingress" {
    for_each = var.ingress_enabled ? [1] : []
    content {
      allow_insecure_connections = false  # Force HTTPS
      external_enabled           = true   # Temporarily external to bypass environment limit
      target_port                = var.container_port
      transport                  = "auto"
      
      traffic_weight {
        percentage      = 100
        latest_revision = true
      }
    }
  }
}