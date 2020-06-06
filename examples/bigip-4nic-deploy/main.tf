provider "azurerm" {
  version = "~>2.0"
  features {}
}
resource "azurerm_resource_group" "rg" {
  name     = "testResourceGroup"
  location = "southindia"
}

module "bigip" {
  source              = "../../modules/MultiNic"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_subnet_id      = module.network.vnet_subnets
}


module "network" {
  source              = "Azure/network/azurerm"
  version             = "3.1.1"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
  subnet_names        = ["mgmt-subnet", "external-subnet", "internal-subnet", "private-subnet"]
}
