output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "agw_subnet_id" {
  description = "ID of the Application Gateway subnet"
  value       = azurerm_subnet.agw.id
}

output "aca_subnet_id" {
  description = "ID of the Container Apps subnet"
  value       = azurerm_subnet.aca.id
}

output "pe_subnet_id" {
  description = "ID of the Private Endpoints subnet"
  value       = azurerm_subnet.pe.id
}