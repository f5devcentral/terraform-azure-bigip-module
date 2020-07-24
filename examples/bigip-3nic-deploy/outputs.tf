output mgmtPublicIP {
  value = module.bigip.mgmtPublicIP
}

output mgmtPublicDNS {
  value = module.bigip.mgmtPublicDNS
}
output bigip_username {
  value = module.bigip.f5_username
}

output bigip_password {
  value = module.bigip.bigip_password
}

output mgmtPort {
  value = module.bigip.mgmtPort
}

output mgmtPublicURL {
  description = "mgmtPublicURL"
  value       = format("https://%s:%s", module.bigip.mgmtPublicDNS, module.bigip.mgmtPort)
}

output bigip_onboard_do {
  value = module.bigip.onboard_do
}
