# resource "azurerm_application_security_group" "web_asg" {
#   name                = "${local.resource_group_name}-web_asg"
#   location            = var.location
#   resource_group_name = local.resource_group_name

#   tags = local.tags
# }

# resource "azurerm_network_interface_application_security_group_association" "web_nic_asg" {
#   network_interface_id          = azurerm_network_interface.web.id
#   application_security_group_id = azurerm_application_security_group.web_asg.id
# }