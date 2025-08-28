# # Main VMSS Outputs
# output "vmss_id" {
#   description = "ID of the main VMSS"
#   value       = module.VMSS.vmss_id
# }

# output "vmss_name" {
#   description = "Name of the main VMSS"
#   value       = module.VMSS.vmss_name
# }

# # Linux VMSS Outputs
# output "linux_vmss_id" {
#   description = "ID of the Linux VMSS"
#   value       = module.VMSS_linux.vmss_id
# }

# output "linux_vmss_name" {
#   description = "Name of the Linux VMSS"
#   value       = module.VMSS_linux.vmss_name
# }

# output "linux_vmss_unique_id" {
#   description = "Unique ID of the Linux VMSS"
#   value       = module.VMSS_linux.vmss_unique_id
# }

# # Windows VMSS Outputs
# output "windows_vmss_id" {
#   description = "ID of the Windows VMSS"
#   value       = module.VMSS_windows.vmss_id
# }

# output "windows_vmss_name" {
#   description = "Name of the Windows VMSS"
#   value       = module.VMSS_windows.vmss_name
# }

# output "windows_vmss_unique_id" {
#   description = "Unique ID of the Windows VMSS"
#   value       = module.VMSS_windows.vmss_unique_id
# }

# Network Outputs
output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = module.VNET["dev-vnet"].vnet_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.VNET["dev-vnet"].private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.VNET["dev-vnet"].public_subnet_ids
}

# VM IP Outputs
# output "vm_private_ips" {
#   description = "Private IP addresses of the VMs"
#   value       = { for k, v in module.Linux_VM : k => v.private_ip_address }
# }

# output "vm_public_ips" {
#   description = "Public IP addresses of the VMs"
#   value       = { for k, v in module.Linux_VM : k => v.public_ip_address }
# }

# output "vm_names" {
#   description = "Names of the VMs"
#   value       = { for k, v in module.Linux_VM : k => v.name }
# }