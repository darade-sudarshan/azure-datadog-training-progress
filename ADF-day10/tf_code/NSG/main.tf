
resource "azurerm_network_security_group" "LinuxNSG" {
  name                = "${local.resource_group_name}-LinuxNSG"
  location            = var.location
  resource_group_name = local.resource_group_name
  # security_rule {
  #   name                       = "Allow all inbound traffic"
  #   priority                   = 100
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "*"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }
tags = local.tags
}
  
resource "azurerm_network_security_group" "WinNSG" {
  name                = "${local.resource_group_name}-WinNSG"
  location            = var.location
  resource_group_name = local.resource_group_name
  # security_rule {
  #   name                       = "Allow all inbound traffic"
  #   priority                   = 100
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "*"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }
tags = local.tags
}


