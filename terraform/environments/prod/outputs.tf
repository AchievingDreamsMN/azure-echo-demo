# Production Environment Outputs

output "container_app_url" {
  description = "URL of the Production Container App"
  value       = module.container_app.container_app_url
}

output "container_app_name" {
  description = "Name of the Production Container App"
  value       = module.container_app.container_app_name
}

output "resource_group_name" {
  description = "Name of the Production resource group"
  value       = module.container_app.resource_group_name
}

output "container_registry_login_server" {
  description = "ACR login server (shared with QA)"
  value       = azurerm_container_registry.main.login_server
}

output "container_registry_name" {
  description = "ACR name"
  value       = azurerm_container_registry.main.name
}

output "key_vault_name" {
  description = "Key Vault name for secrets"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.main.vault_uri
}
