output "bastion_subnet_id" {
  description = "The ID of the Bastion subnet"
  value       = var.create_bastion ? azurerm_subnet.bastion_subnet[0].id : null
}
output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
  
}
output "public_subnet_ids" {
  description = "The IDs of the Public Subnets"
  value       = [
    azurerm_subnet.public_subnet01.id,
    azurerm_subnet.public_subnet02.id
  ]
  
}
output "private_subnet_ids" {
  description = "The IDs of the Private Subnets"
  value       = [
    azurerm_subnet.private_subnet01.id,
    azurerm_subnet.private_subnet02.id
  ]
  
}
output "DB_subnet_ids" {
  description = "The IDs of the Database Subnets"
  value       = [
    azurerm_subnet.db_subnet01.id,
    azurerm_subnet.db_subnet02.id
  ]
  
}
output "Linux_NIC_private_id" {
  description = "The ID of the Linux Network Interface"
  value       = contains(keys(var.network_interfaces), "Linux_NIC_private") ? azurerm_network_interface.nic["Linux_NIC_private"].id : null
}

output "Linux_NIC_public_id" {
  description = "The ID of the Linux Network Interface"
  value       = contains(keys(var.network_interfaces), "Linux_NIC_public") ? azurerm_network_interface.nic["Linux_NIC_public"].id : null
}

output "Windows_NIC_private_id" {
  description = "The ID of the Windows Network Interface"
  value       = contains(keys(var.network_interfaces), "Windows_NIC_private") ? azurerm_network_interface.nic["Windows_NIC_private"].id : null
}

output "Windows_NIC_public_id" {
  description = "The ID of the Windows Network Interface"
  value       = contains(keys(var.network_interfaces), "Windows_NIC_public") ? azurerm_network_interface.nic["Windows_NIC_public"].id : null
}

# IP Address Outputs
output "Linux_NIC_private_ip" {
  description = "Private IP address of Linux NIC"
  value       = contains(keys(var.network_interfaces), "Linux_NIC_private") ? azurerm_network_interface.nic["Linux_NIC_private"].private_ip_address : null
}

output "Linux_NIC_public_ip" {
  description = "Private IP address of Linux public NIC"
  value       = contains(keys(var.network_interfaces), "Linux_NIC_public") ? azurerm_network_interface.nic["Linux_NIC_public"].private_ip_address : null
}

output "Windows_NIC_private_ip" {
  description = "Private IP address of Windows NIC"
  value       = contains(keys(var.network_interfaces), "Windows_NIC_private") ? azurerm_network_interface.nic["Windows_NIC_private"].private_ip_address : null
}

output "Windows_NIC_public_ip" {
  description = "Private IP address of Windows public NIC"
  value       = contains(keys(var.network_interfaces), "Windows_NIC_public") ? azurerm_network_interface.nic["Windows_NIC_public"].private_ip_address : null
}
