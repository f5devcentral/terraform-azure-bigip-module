output "bigip_public_ip" {
  value = module.bigip3nic.public_ip_address
}

output "bigip_public_dns_name" {
  value = module.bigip3nic.public_ip_dns_name
}
output "bigip_username" {
  value = module.bigip3nic.f5_username
}
