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
#Create N-nic bigip
#
module bigip {
  source              = "../../"
  dnsLabel            = format("%s-%s", var.prefix, random_id.id.hex)
  resource_group_name = azurerm_resource_group.rg.name
  mgmt_subnet_id      = [{"subnet_id" = data.azurerm_subnet.mgmt.id , "public_ip" = true}]
  mgmt_securitygroup_id    = [module.mgmt-network-security-group.network_security_group_id ]
  availabilityZones   =  var.availabilityZones
}

/*
resource "local_file" "DOjson1" {
  content  = module.bigip.onboard_do
  filename = "DO.json"
}
*/

#
# Create the Network Module to associate with BIGIP
#

module "network" {
  source              = "Azure/vnet/azurerm"
  vnet_name           = format("%s-vnet-%s", var.prefix, random_id.id.hex)
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.2.0.0/16"]
  subnet_prefixes     = ["10.2.1.0/24"]
  subnet_names        = ["mgmt-subnet"]

  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}

data "azurerm_subnet" "mgmt" {
  name                 = "mgmt-subnet"
  virtual_network_name = module.network.vnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  depends_on = [module.network] 
}

#
# Create the Network Security group Module to associate with BIGIP-Mgmt-Nic
#
module mgmt-network-security-group {
  source                = "Azure/network-security-group/azurerm"
  resource_group_name   = azurerm_resource_group.rg.name
  security_group_name   = format("%s-mgmt-nsg-%s", var.prefix, random_id.id.hex)
  source_address_prefix = ["10.0.1.0/24"]
  custom_rules = [
    {
      name                   = "Allow_Https"
      priority               = "200"
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "tcp"
      destination_port_range = "8443" 
      description            = "description-myhttp"
    },
    {
      name                   = "allow_ssh"
      priority               = "201"
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "tcp"
      destination_port_range = "22"
      description            = "Allow ssh connections"
    }
  ]
  tags = {
    environment = "dev"
    costcenter  = "terraform"
  }
}


