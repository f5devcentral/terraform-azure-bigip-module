output "f5_public_ip" {
  value = data.azurerm_public_ip.bigip1-public-ip.ip_address
}

output "f5_public_dnsname" {
  value = data.azurerm_public_ip.bigip1-public-ip.fqdn
}

output "f5_private_ip" {
  value = azurerm_network_interface.mgmt_nic.private_ip_address
}
output "f5_username" {
  value = var.f5_username
}

output "public_ip_address" {
  description = "The actual ip address allocated for the resource."
  value       = data.azurerm_public_ip.bigip1-public-ip.*.ip_address
}

output "public_ip_dns_name" {
  description = "fqdn to connect to the first vm provisioned."
  value       = azurerm_public_ip.mgmt_public_ip.*.fqdn
}
