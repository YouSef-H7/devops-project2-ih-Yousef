variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vnet_id" {
  description = "ID of the virtual network"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Private DNS Zone for SQL Server
resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  name                  = "sql-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}

# Private DNS Zone for Container Apps (required for internal load balancer)
resource "azurerm_private_dns_zone" "container_apps" {
  name                = "whitedesert-4d6c9740.westus2.azurecontainerapps.io"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Link Container Apps Private DNS Zone to VNet with auto-registration enabled
resource "azurerm_private_dns_zone_virtual_network_link" "container_apps" {
  name                  = "container-apps-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.container_apps.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = true  # Enable auto-registration
  tags                  = var.tags
}

output "sql_private_dns_zone_id" {
  description = "ID of the SQL private DNS zone"
  value       = azurerm_private_dns_zone.sql.id
}