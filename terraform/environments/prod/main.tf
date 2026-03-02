# Production Environment Configuration
# Deploys Echo Server to Azure Container Apps for Production

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85.0"
    }
  }

  # Backend configuration for Prod state storage
  # Run scripts/bootstrap.ps1 first, then update these values
  backend "azurerm" {
    resource_group_name  = "demo-bootstrap-rg"
    storage_account_name = "yourstatestorageacct"  # Update after bootstrap
    container_name       = "tfstate"
    key                  = "echo-server-prod.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Create ACR in prod (shared with QA)
resource "azurerm_resource_group" "acr" {
  name     = "demo-${var.project_name}-acr-rg"
  location = var.location

  tags = {
    Environment = "Shared"
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Demo        = "true"
  }
}

resource "azurerm_container_registry" "main" {
  name                = replace("${var.project_name}acr", "-", "")
  resource_group_name = azurerm_resource_group.acr.name
  location            = azurerm_resource_group.acr.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    Environment = "Shared"
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

module "container_app" {
  source = "../../modules/container-app"

  project_name        = var.project_name
  environment         = "prod"
  location            = var.location
  resource_group_name = "demo-${var.project_name}-prod-rg"

  image_name = var.image_name
  image_tag  = var.image_tag

  # Production scaling (higher availability)
  min_replicas = 1
  max_replicas = 5
  cpu          = 0.5
  memory       = "1Gi"

  # Longer log retention for production
  log_retention_days = 90

  # Use the ACR created above
  container_registry_server   = azurerm_container_registry.main.login_server
  container_registry_username = azurerm_container_registry.main.admin_username
  container_registry_password = azurerm_container_registry.main.admin_password

  tags = {
    Environment = "Production"
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Demo        = "true"
  }
}
