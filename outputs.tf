output mgmtPublicIP {
  description = "The actual ip address allocated for the resource."
  value       = data.azurerm_public_ip.f5vm01mgmtpip.ip_address
}

output mgmtPublicDNS {
  description = "fqdn to connect to the first vm provisioned."
  value       = data.azurerm_public_ip.f5vm01mgmtpip.fqdn
}


output mgmtPort {
  description = "Mgmt Port"
  value       = local.total_nics > 1 ? "443" : "8443"
}


output f5_username {
  value = var.f5_username
}

output bigip_password {
  description = <<-EOT
 "Password for bigip user ( if dynamic_password is choosen it will be random generated password or if azure_keyvault is choosen it will be key vault secret name )
  EOT
   value       = (var.f5_password == "") ? (var.az_key_vault_authentication ? data.azurerm_key_vault_secret.bigip_admin_password[0].name : random_string.password.result) : var.f5_password
}

output onboard_do {
   value      = local.total_nics > 3 ?  " " : (local.total_nics > 2 ? data.template_file.clustermemberDO3[0].rendered :(local.total_nics== 2 ? data.template_file.clustermemberDO2[0].rendered : data.template_file.clustermemberDO1[0].rendered ))
  depends_on = [data.template_file.clustermemberDO1[0], data.template_file.clustermemberDO2[0], data.template_file.clustermemberDO3[0]]

}

output "public_addresses" {
  description = "List of BIG-IP public addresses"
  value   = concat(azurerm_public_ip.external_public_ip.*.ip_address, azurerm_public_ip.secondary_external_public_ip.*.ip_address)
}

output "private_addresses" {
  description = "List of BIG-IP private addresses"
  value   = concat(azurerm_network_interface.external_nic.*.private_ip_addresses, azurerm_network_interface.external_public_nic.*.private_ip_addresses, azurerm_network_interface.internal_nic.*.private_ip_address)
}
