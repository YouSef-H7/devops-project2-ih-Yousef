variable "name" {
  description = "Name of the container app"
  type        = string
}

variable "container_apps_env_id" {
  description = "ID of the Container Apps Environment"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}

variable "cpu_requests" {
  description = "CPU requests for the container"
  type        = string
  default     = "0.25"
}

variable "memory_requests" {
  description = "Memory requests for the container"
  type        = string
  default     = "0.5Gi"
}

variable "min_replicas" {
  description = "Minimum number of replicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of replicas"
  type        = number
  default     = 10
}

variable "ingress_enabled" {
  description = "Enable ingress for the container app"
  type        = bool
  default     = true
}

variable "ingress_external" {
  description = "Allow external traffic to the container app"
  type        = bool
  default     = true
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name        = string
    value       = optional(string)
    secret_name = optional(string)
  }))
  default = []
}

variable "secrets" {
  description = "Secrets for the container app"
  type = list(object({
    name  = string
    value = string
  }))
  default   = []
  sensitive = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}