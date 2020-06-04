provider azurerm {
  version = "~>2.0"
  features {}
}

#
# Create a random id
#
resource random_id id {
  byte_length = 2
}

#
# Create a resource group
#
resource azurerm_resource_group rg {
  name     = format("%s-rg-%s", var.prefix, random_id.id.hex)
  location = var.location
}

#
# Create the B
module bigip1nic {
  source              = "../../modules/1NIC"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_subnet_id      = [module.network.vnet_subnets[0]]
}


module network {
  source              = "Azure/network/azurerm"
  version             = "3.1.1"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["mgmt-subnet"]
}


