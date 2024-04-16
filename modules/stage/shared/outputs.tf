output "resource_group_id" {
  description = "Unique identifier of the resource group owning all resources of this solution"
  value       = azurerm_resource_group.owner.id
}

output "resource_group_fqn" {
  description = "Fully qualified name of the resource group owning all resources of this solution"
  value       = azurerm_resource_group.owner.name
}

output "key_vault_id" {
  description = "Unique identifier name of the key vault managing all confidential data of this solution"
  value       = module.key_vault.key_vault_id
}

output "key_vault_fqn" {
  description = "Fully qualified name of the key vault managing all confidential data of this solution"
  value       = module.key_vault.key_vault_name
}

output "log_analytics_workspace_id" {
  description = "Unique identifier name of the log analytics workspace managing all telemetry data of this solution"
  value       = module.log_analytics_workspace.log_analytics_workspace_id
}

output "log_analytics_workspace_fqn" {
  description = "Fully qualified name of the log analytics workspace managing all telemetry data of this solution"
  value       = module.log_analytics_workspace.log_analytics_workspace_name
}

output "public_dns_zone_id" {
  description = "Unique identifier of the public DNS zone managing all DNS records routing traffic to this solution"
  value       = module.public_dns.dns_zone_id
}
