output mgmtPublicIP {
  value = module.bigip.mgmtPublicIP
}

output mgmtPublicDNS {
  value = module.bigip.mgmtPublicDNS
}
output adminUsername {
  value = module.bigip.f5_username
}

output mgmtPort {
  value = module.bigip.mgmtPort
}

output mgmtPublicURL {
  description = "mgmtPublicURL"
  value       = format("https://%s:%s", module.bigip.mgmtPublicDNS, module.bigip.mgmtPort)
}
