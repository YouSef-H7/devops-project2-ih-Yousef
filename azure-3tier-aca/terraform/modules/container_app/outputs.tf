output "id" {
  description = "ID of the container app"
  value       = azurerm_container_app.main.id
}

output "name" {
  description = "Name of the container app"
  value       = azurerm_container_app.main.name
}

output "fqdn" {
  description = "FQDN of the container app"
  value       = var.ingress_enabled ? azurerm_container_app.main.ingress[0].fqdn : null
}