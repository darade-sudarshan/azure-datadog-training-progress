resource "azurerm_mssql_server" "mssqldb" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.sql_server_version
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password

  tags = var.tags
}

resource "azurerm_mssql_database" "mssqldb" {
  name           = var.database_name
  server_id      = azurerm_mssql_server.mssqldb.id
  collation      = var.collation
  sku_name       = var.sku_name
  max_size_gb    = var.max_size_gb

  tags = var.tags
}

resource "azurerm_mssql_firewall_rule" "allow_azure" {
  count            = var.allow_azure_services ? 1 : 0
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.mssqldb.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "custom_rules" {
  for_each         = var.firewall_rules
  name             = each.key
  server_id        = azurerm_mssql_server.mssqldb.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}