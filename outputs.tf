output f5_username {
  value = var.f5_username
}

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