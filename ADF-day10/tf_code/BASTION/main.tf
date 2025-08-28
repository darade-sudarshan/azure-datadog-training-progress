resource "azurerm_public_ip" "bastion_ip" {
  name                = "${local.resource_group_name}-bastion-ip"
  location            = var.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_bastion_host" "bastion_host" {
  name                = "${local.resource_group_name}-bastion-host"
  location            = var.location
  resource_group_name = local.resource_group_name
  sku                 = var.bastion_sku

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }
  tags = local.tags
}