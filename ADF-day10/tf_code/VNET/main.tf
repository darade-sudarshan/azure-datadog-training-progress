# Terraform configuration for Azure Virtual Network
# This file defines the local values used in the Azure VNET module.

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.resource_group_name}-${var.vnet_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  #dns_servers         = var.dns_servers_address

  tags = local.tags
}