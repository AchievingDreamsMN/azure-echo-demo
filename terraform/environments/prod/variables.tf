# Production Environment Variables

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
