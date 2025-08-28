output "data_factory_id" {
  description = "ID of the Data Factory"
  value       = azurerm_data_factory.adf.id
}

output "data_factory_name" {
  description = "Name of the Data Factory"
  value       = azurerm_data_factory.adf.name
}

output "identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = var.enable_managed_identity ? azurerm_data_factory.adf.identity[0].principal_id : null
}

output "identity_tenant_id" {
  description = "Tenant ID of the managed identity"
  value       = var.enable_managed_identity ? azurerm_data_factory.adf.identity[0].tenant_id : null
}