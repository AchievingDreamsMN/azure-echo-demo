# QA Environment Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "echo-server"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "image_name" {
  description = "Container image name"
  type        = string
  default     = "echo-server"
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "latest"
}

variable "container_registry_server" {
  description = "ACR login server URL"
  type        = string
}

variable "container_registry_username" {
  description = "ACR username"
  type        = string
}

variable "container_registry_password" {
  description = "ACR password"
  type        = string
  sensitive   = true
}
