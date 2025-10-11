# أساسيات
prefix              = "yousef-v5"
resource_group_name = "Yousef-v5-rg"
location            = "westus2"
environment         = "prod"

# Network Configuration
vnet_address_space = ["10.2.0.0/16"]
agw_subnet_cidr    = "10.2.1.0/24"
aca_subnet_cidr    = "10.2.2.0/23"
pe_subnet_cidr     = "10.2.4.0/24"
aca_ca_subnet_cidr = "10.2.6.0/23"

# Resource Names
aca_environment_name         = "yousef-v5-aca-env-prod"
app_gateway_name             = "agw-yousef-v5-burgerbuilder"
log_analytics_workspace_name = "law-yousef-v5-burgerbuilder"

# SQL Configuration
sql_server_name   = "sql-yousef-v5-burgerbuilder"
sql_database_name = "sqldb-yousef-v5-burgerbuilder"
sql_admin_login   = "yousefv5-admin"

# Docker Hub
dockerhub_org  = "youkim7"
dockerhub_user = "youkim7"

# Image Tags
fe_image_tag  = "dev-010"
api_image_tag = "yousef-v6-final"

# Tags
tags = {
  Environment = "Production"
  Project     = "Yousef-v5-BurgerBuilder"
  Owner       = "Yousef-v5"
}