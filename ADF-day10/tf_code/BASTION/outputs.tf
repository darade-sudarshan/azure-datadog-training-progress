output "myip" {
  description = "Current public IP address"
  value       = data.http.myip.response_body
  
}
output "bastion_host_public_ip" {
   description = "the Bastion Public IP"
    value       = azurerm_public_ip.bastion_ip.ip_address  
}