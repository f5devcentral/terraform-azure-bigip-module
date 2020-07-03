output bigip_public_ip {
  value = module.bigip1nic.public_ip_address
}

output bigip_public_dns_name {
  value = module.bigip1nic.public_ip_dns_name
}
output bigip_username {
  value = module.bigip1nic.f5_username
}

output f5vm_public_name {
  value = module.bigip1nic.public_ip_dns_name
}
