# Basic configuration
prefix      = "burger-dev"
location    = "eastus"
environment = "dev"

# Resource names
resource_group_name          = "rg-burgerbuilder-dev"
aca_environment_name         = "aca-env-dev"
app_gateway_name             = "agw-burgerbuilder-dev"
log_analytics_workspace_name = "law-burgerbuilder-dev"

# SQL Database (server name must be lowercase and globally unique)
sql_server_name   = "sql-burgerbuilder-dev01"
sql_database_name = "sqldb-burgerbuilder-dev"
sql_admin_login   = "sqladmin"

# Networking
vnet_address_space = ["10.0.0.0/16"]
agw_subnet_cidr    = "10.0.1.0/24"
aca_subnet_cidr    = "10.0.2.0/23"
pe_subnet_cidr     = "10.0.4.0/24"

# Docker Hub
dockerhub_org  = "youkim7"
dockerhub_user = "youkim7"

# Image tags
fe_image_tag  = "dev-001"
api_image_tag = "dev-001"

# Tags
tags = {
  Environment = "Development"
  Project     = "BurgerBuilder"
  Owner       = "DevOps Team"
}