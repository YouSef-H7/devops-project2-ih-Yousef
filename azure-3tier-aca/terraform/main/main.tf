# Generate random password for SQL Server
resource "random_password" "sql_admin_password" {
  length  = 20
  special = true
}

# Resource Group
module "resource_group" {
  source = "../modules/resource_group"

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Log Analytics Workspace
module "log_analytics" {
  source = "../modules/log_analytics"

  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags
}

# Virtual Network and Subnets
module "network" {
  source = "../modules/network"

  resource_group_name = module.resource_group.name
  location            = var.location
  vnet_address_space  = var.vnet_address_space
  agw_subnet_cidr     = var.agw_subnet_cidr
  aca_subnet_cidr     = var.aca_subnet_cidr
  pe_subnet_cidr      = var.pe_subnet_cidr
  environment         = var.environment
  tags                = var.tags
}

# Private DNS Zones
module "dns" {
  source = "../modules/dns"

  resource_group_name = module.resource_group.name
  vnet_id             = module.network.vnet_id
  tags                = var.tags
}

# SQL Server with Private Endpoint
module "sql" {
  source = "../modules/sql"

  server_name            = var.sql_server_name
  database_name          = var.sql_database_name
  admin_login            = var.sql_admin_login
  admin_password         = random_password.sql_admin_password.result
  resource_group_name    = module.resource_group.name
  location               = var.location
  pe_subnet_id           = module.network.pe_subnet_id
  private_dns_zone_id    = module.dns.sql_private_dns_zone_id
  tags                   = var.tags
}

# Container Apps Environment
module "container_apps_env" {
  source = "../modules/container_apps_env"

  name                      = var.aca_environment_name
  resource_group_name       = module.resource_group.name
  location                  = var.location
  log_analytics_workspace_id = module.log_analytics.workspace_id
  subnet_id                 = module.network.aca_subnet_id
  tags                      = var.tags
}

# Frontend Container App
module "frontend_container_app" {
  source = "../modules/container_app"

  name                    = "frontend"
  container_apps_env_id   = module.container_apps_env.id
  resource_group_name     = module.resource_group.name
  container_image         = "docker.io/${var.dockerhub_org}/frontend:dev-009"
  container_port          = 80
  cpu_requests           = "0.25"
  memory_requests        = "0.5Gi"
  min_replicas           = 1
  max_replicas           = 10
  ingress_enabled        = true
  ingress_external       = true
  environment_variables  = [
    {
      name  = "VITE_API_BASE_URL"
      value = "https://4.155.169.159"
    }
  ]
  tags                   = var.tags
}

# Backend Container App
module "backend_container_app" {
  source = "../modules/container_app"

  name                    = "backend"
  container_apps_env_id   = module.container_apps_env.id
  resource_group_name     = module.resource_group.name
  container_image         = "docker.io/${var.dockerhub_org}/backend:${var.api_image_tag}"
  container_port          = 8080
  cpu_requests           = "0.5"
  memory_requests        = "1Gi"
  min_replicas           = 1
  max_replicas           = 10
  ingress_enabled        = true
  ingress_external       = true
  environment_variables = [
    {
      name        = "DB_HOST"
      value       = module.sql.server_fqdn
      secret_name = null
    },
    {
      name        = "DB_PORT"
      value       = "1433"
      secret_name = null
    },
    {
      name        = "DB_NAME"
      value       = var.sql_database_name
      secret_name = null
    },
    {
      name        = "DB_USERNAME"
      value       = var.sql_admin_login
      secret_name = null
    },
    {
      name        = "DB_PASSWORD"
      value       = null
      secret_name = "sql-password"
    },
    {
      name        = "DB_DRIVER"
      value       = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
      secret_name = null
    },
    {
      name        = "SPRING_PROFILES_ACTIVE"
      value       = "azure"
      secret_name = null
    }
  ]
  secrets = [
    {
      name  = "sql-password"
      value = random_password.sql_admin_password.result
    }
  ]
  tags = var.tags
}

# Application Gateway
module "app_gateway" {
  source = "../modules/app_gateway"

  name                = var.app_gateway_name
  resource_group_name = module.resource_group.name
  location            = var.location
  subnet_id           = module.network.agw_subnet_id
  frontend_fqdn       = module.frontend_container_app.fqdn
  backend_fqdn        = module.backend_container_app.fqdn
  tags                = var.tags
}