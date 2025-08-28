resource "azurerm_network_interface" "nic" {
  for_each = local.network_interfaces
  
  name                = "${local.resource_group_name}-${each.key}"
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}