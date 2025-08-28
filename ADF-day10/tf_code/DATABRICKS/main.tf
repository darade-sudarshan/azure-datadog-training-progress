resource "azurerm_databricks_workspace" "databricks" {
  name                = var.databricks_workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  dynamic "custom_parameters" {
    for_each = var.enable_custom_vnet ? [1] : []
    content {
      no_public_ip                                         = var.no_public_ip
      virtual_network_id                                   = var.virtual_network_id
      private_subnet_name                                  = var.private_subnet_name
      public_subnet_name                                   = var.public_subnet_name
      private_subnet_network_security_group_association_id = var.private_subnet_nsg_association_id
      public_subnet_network_security_group_association_id  = var.public_subnet_nsg_association_id
    }
  }

  tags = var.tags
}

resource "azurerm_databricks_workspace_root_dbfs_customer_managed_key" "databricks" {
  count               = var.enable_customer_managed_key ? 1 : 0
  workspace_id        = azurerm_databricks_workspace.databricks.id
  key_vault_key_id    = var.key_vault_key_id
}