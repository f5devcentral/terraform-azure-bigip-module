output "bigip_public_ip" {
  value = module.bigip2nic.public_ip_address
}

output "bigip_public_dns_name" {
  value = module.bigip2nic.public_ip_dns_name
}
output "bigip_username" {
  value = module.bigip2nic.f5_username
}
