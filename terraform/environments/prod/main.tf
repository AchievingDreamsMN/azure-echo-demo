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
    Demo        = "true"
  }
}

# Key Vault for secrets (shared across environments)
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                       = "demo-${var.project_name}-kv"
  location                   = azurerm_resource_group.acr.location
  resource_group_name        = azurerm_resource_group.acr.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false  # Allow immediate delete for demo

  # Access policy for the service principal running Terraform/GitHub Actions
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge"
    ]
  }

  tags = {
    Environment = "Shared"
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Demo        = "true"
  }
}

# Store ACR credentials in Key Vault
resource "azurerm_key_vault_secret" "acr_server" {
  name         = "acr-login-server"
  value        = azurerm_container_registry.main.login_server
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "acr_username" {
  name         = "acr-username"
  value        = azurerm_container_registry.main.admin_username
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "acr_password" {
  name         = "acr-password"
  value        = azurerm_container_registry.main.admin_password
  key_vault_id = azurerm_key_vault.main.id
}

# Storage Account for build artifacts
resource "azurerm_storage_account" "artifacts" {
  name                     = replace("demo${var.project_name}art", "-", "")
  resource_group_name      = azurerm_resource_group.acr.name
  location                 = azurerm_resource_group.acr.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    delete_retention_policy {
      days = 7  # Keep deleted blobs for 7 days (demo-friendly)
    }
  }

  tags = {
    Environment = "Shared"
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Demo        = "true"
  }
}

# Container for test reports
resource "azurerm_storage_container" "test_reports" {
  name                  = "test-reports"
  storage_account_id    = azurerm_storage_account.artifacts.id
  container_access_type = "private"
}

# Container for build logs
resource "azurerm_storage_container" "build_logs" {
  name                  = "build-logs"
  storage_account_id    = azurerm_storage_account.artifacts.id
  container_access_type = "private"
}

# Container for release artifacts
resource "azurerm_storage_container" "releases" {
  name                  = "releases"
  storage_account_id    = azurerm_storage_account.artifacts.id
  container_access_type = "private"
}

# Store artifact storage connection string in Key Vault
resource "azurerm_key_vault_secret" "artifacts_connection_string" {
  name         = "artifacts-storage-connection-string"
  value        = azurerm_storage_account.artifacts.primary_connection_string
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "artifacts_account_name" {
  name         = "artifacts-storage-account-name"
  value        = azurerm_storage_account.artifacts.name
  key_vault_id = azurerm_key_vault.main.id
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
