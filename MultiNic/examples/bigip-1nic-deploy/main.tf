provider "azurerm" {
  version = "~>2.0"
  features {}
}
resource "azurerm_resource_group" "rg" {
  name     = "testResourceGroup"
  location = "southindia"
}

module "bigip3nic" {
  source              = "../../"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_subnet_id      = [module.network.vnet_subnets[0], module.network.vnet_subnets[1], module.network.vnet_subnets[2]]
  nb_public_ip        = 1
  nb_nics             = 1
}


module "network" {
  source              = "Azure/network/azurerm"
  version             = "3.0.0"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["mgmt-subnet", "external-subnet","internal-subnet"]
}

output "f5vm_public_name" {
  value = module.bigip3nic.public_ip_dns_name
}