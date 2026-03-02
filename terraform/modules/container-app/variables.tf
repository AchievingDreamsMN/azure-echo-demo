# Variables for Container App module

variable "project_name" {
  description = "Name of the project, used as prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name (qa, prod)"
  type        = string
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "image_name" {
  description = "Name of the container image"
  type        = string
  default     = "echo-server"
}

variable "image_tag" {
  description = "Tag of the container image"
  type        = string
  default     = "latest"
}

variable "min_replicas" {
  description = "Minimum number of container replicas"
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "Maximum number of container replicas"
  type        = number
  default     = 3
}

variable "cpu" {
  description = "CPU allocation for the container"
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "Memory allocation for the container"
  type        = string
  default     = "0.5Gi"
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

variable "create_container_registry" {
  description = "Whether to create a container registry (typically only for prod)"
  type        = bool
  default     = false
}

variable "acr_sku" {
  description = "SKU for the Azure Container Registry"
  type        = string
  default     = "Basic"
}

variable "container_registry_server" {
  description = "Login server URL for the container registry"
  type        = string
}

variable "container_registry_username" {
  description = "Username for the container registry"
  type        = string
}

variable "container_registry_password" {
  description = "Password for the container registry"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
