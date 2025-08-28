resource "azurerm_subnet" "public_subnet01" {
  name                 = "${local.resource_group_name}-public-subnet01"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.public_subnet_prefixes[0]]
  default_outbound_access_enabled = true
}
resource "azurerm_subnet" "public_subnet02" {
  name                 = "${local.resource_group_name}-public-subnet02"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.public_subnet_prefixes[1]]
  default_outbound_access_enabled = true
  
}

resource "azurerm_subnet" "private_subnet01" {
  name                 = "${local.resource_group_name}-private-subnet01"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_subnet_prefixes[0]]
  default_outbound_access_enabled = true
}
resource "azurerm_subnet" "private_subnet02" {
  name                 = "${local.resource_group_name}-private-subnet02"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_subnet_prefixes[1]]
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "db_subnet01" {
  name                 = "${local.resource_group_name}-db-subnet01"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.DB_subnet_prefixes[0]]
  default_outbound_access_enabled = false
}
resource "azurerm_subnet" "db_subnet02" {
  name                 = "${local.resource_group_name}-db-subnet02"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.DB_subnet_prefixes[1]]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "bastion_subnet" {
  count = var.create_bastion ? 1 : 0
  
  name                 = "AzureBastionSubnet" # Azure requires this specific name for the Bastion subnet
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.bastion_subnet_prefixes[0]]

  default_outbound_access_enabled = false
}