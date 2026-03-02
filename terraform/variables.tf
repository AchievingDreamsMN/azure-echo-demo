# Variables for Azure Container Apps deployment

variable "project_name" {
  description = "Name of the project, used as prefix for all resources"
  type        = string
  default     = "echo-server"
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "echo-server-rg"
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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Demo"
    Project     = "EchoServer"
    ManagedBy   = "Terraform"
  }
}
