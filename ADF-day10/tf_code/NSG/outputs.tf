output "myip" {
  description = "Current public IP address"
  value       = data.http.myip.response_body
  
}
output "LinuxNSG_id" {
  description = "The ID of the Linux Network Security Group"
  value       = azurerm_network_security_group.LinuxNSG.id
  
}
output "WinNSG_id" {
  description = "The ID of the Windows Network Security Group"
  value       = azurerm_network_security_group.WinNSG.id
  
}