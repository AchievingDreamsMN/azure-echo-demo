# QA Environment Configuration
# Deploys Echo Server to Azure Container Apps for QA testing

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85.0"
    }
  }

  # Backend configuration for QA state storage
  backend "azurerm" {
    resource_group_name  = "demo-bootstrap-rg"
    storage_account_name = "demotfstate4518"
    container_name       = "tfstate"
    key                  = "echo-server-qa.tfstate"
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

module "container_app" {
  source = "../../modules/container-app"

  project_name        = var.project_name
  environment         = "qa"
  location            = var.location
  resource_group_name = "demo-${var.project_name}-qa-rg"

  image_name = var.image_name
  image_tag  = var.image_tag

  # QA-specific scaling (lower for cost savings)
  min_replicas = 0
  max_replicas = 2
  cpu          = 0.25
  memory       = "0.5Gi"

  # Use free tier log retention for QA (only 7 or 30-730 allowed)
  log_retention_days = 30

  # ACR credentials (shared from prod or provided)
  container_registry_server   = var.container_registry_server
  container_registry_username = var.container_registry_username
  container_registry_password = var.container_registry_password

  tags = {
    Environment = "QA"
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Demo        = "true"
  }
}
