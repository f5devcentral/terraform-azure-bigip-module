output "f5_username" {
  value = var.f5_username
}

output "public_ip_address" {
  description = "The actual ip address allocated for the resource."
  value       = data.azurerm_public_ip.f5vm01mgmtpip.ip_address
}

output "public_ip_dns_name" {
  description = "fqdn to connect to the first vm provisioned."
  value       = azurerm_public_ip.mgmt_public_ip.fqdn
}

output "public_ip_id" {
  description = "id of the public ip address provisoned."
  value       = azurerm_public_ip.mgmt_public_ip.id
}