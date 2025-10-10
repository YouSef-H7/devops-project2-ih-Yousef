variable "name" {
  description = "Name of the Application Gateway"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for Application Gateway"
  type        = string
}

variable "frontend_fqdn" {
  description = "FQDN of the frontend container app"
  type        = string
}

variable "backend_fqdn" {
  description = "FQDN of the backend container app"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}