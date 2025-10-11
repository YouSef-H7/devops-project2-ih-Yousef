variable "prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "uksouth"
}

# اختياري حالياً (نستخدم IP بدلاً من الدومين)
variable "app_gateway_public_hostname" {
  description = "Public hostname (FQDN) served by Application Gateway (e.g., api.yourdomain.com) — optional when using IP"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "aca_environment_name" {
  description = "Name of the Container Apps Environment"
  type        = string
}

variable "app_gateway_name" {
  description = "Name of the Application Gateway"
  type        = string
}

variable "sql_server_name" {
  description = "Name of the SQL Server"
  type        = string
}

variable "sql_database_name" {
  description = "Name of the SQL Database"
  type        = string
}

variable "sql_admin_login" {
  description = "SQL Server admin login"
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "agw_subnet_cidr" {
  description = "CIDR block for Application Gateway subnet"
  type        = string
}

variable "aca_subnet_cidr" {
  description = "CIDR block for (old) Container Apps subnet"
  type        = string
}

# ✅ جديد: سبنت بيئة الـ Container Apps المفوّضة
variable "aca_ca_subnet_cidr" {
  description = "CIDR block for Container Apps Environment subnet (delegated to Microsoft.App/environments)"
  type        = string
}

variable "pe_subnet_cidr" {
  description = "CIDR block for Private Endpoints subnet"
  type        = string
}

variable "dockerhub_org" {
  description = "Docker Hub organization/username"
  type        = string
}

variable "dockerhub_user" {
  description = "Docker Hub username"
  type        = string
}

variable "fe_image_tag" {
  description = "Frontend image tag"
  type        = string
}

variable "api_image_tag" {
  description = "API/Backend image tag"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
