data "azurerm_resource_group" "EIC_RG" {
  name = var.resource_group_name
}

data "http" "myip" {
  url = "https://checkip.amazonaws.com" # "https://ipv4.icanhazip.com"
}
