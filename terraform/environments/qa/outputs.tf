# QA Environment Outputs

output "container_app_url" {
  description = "URL of the QA Container App"
  value       = module.container_app.container_app_url
}

output "container_app_name" {
  description = "Name of the QA Container App"
  value       = module.container_app.container_app_name
}

output "resource_group_name" {
  description = "Name of the QA resource group"
  value       = module.container_app.resource_group_name
}
