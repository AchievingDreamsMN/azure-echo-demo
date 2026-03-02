# Outputs from Container App module

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "container_app_url" {
  description = "URL of the deployed Container App"
  value       = "https://${azurerm_container_app.echo_server.ingress[0].fqdn}"
}

output "container_app_name" {
  description = "Name of the Container App"
  value       = azurerm_container_app.echo_server.name
}

output "container_registry_login_server" {
  description = "Login server for the Container Registry (if created)"
  value       = var.create_container_registry ? azurerm_container_registry.main[0].login_server : null
}

output "container_registry_name" {
  description = "Name of the Container Registry (if created)"
  value       = var.create_container_registry ? azurerm_container_registry.main[0].name : null
}

output "container_registry_admin_username" {
  description = "Admin username for the Container Registry (if created)"
  value       = var.create_container_registry ? azurerm_container_registry.main[0].admin_username : null
}

output "container_registry_admin_password" {
  description = "Admin password for the Container Registry (if created)"
  value       = var.create_container_registry ? azurerm_container_registry.main[0].admin_password : null
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "environment_name" {
  description = "Name of the Container App Environment"
  value       = azurerm_container_app_environment.main.name
}
