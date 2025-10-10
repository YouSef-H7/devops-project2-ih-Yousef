output "workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "workspace_key" {
  description = "Primary shared key of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}