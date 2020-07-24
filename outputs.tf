
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
  value       = var.nb_nics > 1 ? "443" : "8443"
}

output f5_username {
  value = var.f5_username
}

output bigip_password {
  description = <<-EOT
 "Password for bigip user ( if dynamic_password is choosen it will be random generated password or if azure_keyvault is choosen it will be key vault secret name )
  EOT
  value       = var.az_key_vault_authentication ? data.azurerm_key_vault_secret.bigip_admin_password[0].name : random_password.password.result
}

output onboard_do {
  value      = var.nb_nics > 1 ? (var.nb_nics == 2 ? data.template_file.clustermemberDO2[0].rendered : data.template_file.clustermemberDO3[0].rendered) : data.template_file.clustermemberDO1[0].rendered
  depends_on = [data.template_file.clustermemberDO1[0].rendered, data.template_file.clustermemberDO2[0].rendered, data.template_file.clustermemberDO3[0].rendered]
}
