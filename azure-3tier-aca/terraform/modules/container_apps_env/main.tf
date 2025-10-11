resource "azurerm_container_app_environment" "main" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # ربط الـ ACA Environment على سبنت مفوض لـ Microsoft.App/environments
  infrastructure_subnet_id       = var.subnet_id

  # اختياري لكنه أنظف مع App Gateway: يجعل الـ Environment داخلية فقط (ILB)
  internal_load_balancer_enabled = true

  tags = var.tags
}

# Diagnostic settings for Container Apps Environment
resource "azurerm_monitor_diagnostic_setting" "aca_env" {
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_container_app_environment.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "ContainerAppConsoleLogs" }
  enabled_log { category = "ContainerAppSystemLogs" }
  metric      { category = "AllMetrics" }
}
