output "server_id" {
  description = "ID of the SQL Server"
  value       = azurerm_mssql_server.main.id
}

output "server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.main.name
}

output "server_fqdn" {
  description = "FQDN of the SQL Server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "database_id" {
  description = "ID of the SQL Database"
  value       = azurerm_mssql_database.main.id
}

output "database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.main.name
}

output "private_endpoint_id" {
  description = "ID of the private endpoint"
  value       = azurerm_private_endpoint.sql.id
}