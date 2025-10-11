variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
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
  description = "CIDR block for Container Apps subnet"
  type        = string
}

variable "aca_ca_subnet_cidr" {
  description = "CIDR block for Container Apps Environment subnet (delegated to Microsoft.App/environments)"
  type        = string
}

variable "pe_subnet_cidr" {
  description = "CIDR block for Private Endpoints subnet"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
