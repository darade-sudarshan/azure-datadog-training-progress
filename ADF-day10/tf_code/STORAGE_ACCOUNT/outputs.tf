output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.storageaccount.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.storageaccount.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint"
  value       = azurerm_storage_account.storageaccount.primary_blob_endpoint
}

output "primary_access_key" {
  description = "Primary access key"
  value       = azurerm_storage_account.storageaccount.primary_access_key
  sensitive   = true
}

output "connection_string" {
  description = "Storage account connection string"
  value       = azurerm_storage_account.storageaccount.primary_connection_string
  sensitive   = true
}