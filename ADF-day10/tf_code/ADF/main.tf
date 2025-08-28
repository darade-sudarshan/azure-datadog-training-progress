resource "azurerm_data_factory" "adf" {
  name                = var.data_factory_name
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "identity" {
    for_each = var.enable_managed_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  tags = var.tags
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "storage" {
  for_each            = var.storage_linked_services
  name                = each.key
  data_factory_id     = azurerm_data_factory.adf.id
  connection_string   = each.value.connection_string
}

resource "azurerm_data_factory_dataset_azure_blob" "datasets" {
  for_each            = var.blob_datasets
  name                = each.key
  data_factory_id     = azurerm_data_factory.adf.id
  linked_service_name = each.value.linked_service_name
  path                = each.value.path
  filename            = each.value.filename
}