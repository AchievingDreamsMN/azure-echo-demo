# Outputs from Azure Container Apps deployment

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "container_app_url" {
  description = "URL of the deployed Container App"
  value       = "https://${azurerm_container_app.echo_server.ingress[0].fqdn}"
}

output "container_registry_login_server" {
  description = "Login server for the Container Registry"
  value       = azurerm_container_registry.main.login_server
}

output "container_registry_name" {
  description = "Name of the Container Registry"
  value       = azurerm_container_registry.main.name
}

output "container_app_name" {
  description = "Name of the Container App"
  value       = azurerm_container_app.echo_server.name
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}
