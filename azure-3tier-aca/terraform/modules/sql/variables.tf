variable "server_name" {
  description = "Name of the SQL Server"
  type        = string
}

variable "database_name" {
  description = "Name of the SQL Database"
  type        = string
}

variable "admin_login" {
  description = "Administrator login for SQL Server"
  type        = string
}

variable "admin_password" {
  description = "Administrator password for SQL Server"
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "pe_subnet_id" {
  description = "ID of the subnet for private endpoints"
  type        = string
}

variable "private_dns_zone_id" {
  description = "ID of the private DNS zone for SQL Server"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}