
output "network_interface_ids" {
  description = "ids of the vm nics provisoned."
  value       = azurerm_network_interface.vm.*.id
}

output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = azurerm_network_interface.vm.*.private_ip_address
}

output "network_interface_list" {
  description = "ids of the vm nics provisoned."
  value       = element(azurerm_network_interface.vm.*.id, 0)
}

