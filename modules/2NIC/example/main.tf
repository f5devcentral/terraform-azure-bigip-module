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
# Create a BIG-IP
#
module bigip2nic {
  source              = "../"
  dnsLabel            = format("%s-%s", var.prefix, random_id.id.hex)
  resource_group_name = azurerm_resource_group.rg.name
  vnet_subnet_id      = module.network.vnet_subnets
  //vnet_subnet_security_group_ids = local.vnet_subnet_network_security_group_ids
}

#
# Create the Azure network resources
#
module network {
  source = "Azure/network/azurerm"
  //version             = "3.1.1"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24"]
  subnet_names        = ["mgmt-subnet", "external-subnet"]
}

#
# Create the Network Security group Module to associate with BIGIP-Mgmt-Nic
#
module "mgmt-network-security-group" {
  source                = "Azure/network-security-group/azurerm"
  resource_group_name   = azurerm_resource_group.rg.name
  security_group_name   = format("%s-mgmt-nsg-%s", var.prefix, random_id.id.hex)
  source_address_prefix = ["10.0.1.0/24"]
  predefined_rules = [
    {
      name     = "SSH"
      priority = "500"
    },
    {
      name              = "LDAP"
      source_port_range = "1024-1026"
    }
  ]
  custom_rules = [
    {
      name                   = "myhttp"
      priority               = "200"
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "tcp"
      destination_port_range = "443"
      description            = "description-myhttp"
    }
  ]
  tags = {
    environment = "dev"
    costcenter  = "terraform"
  }
}

#
# Create the Network Security group Module to associate with BIGIP-External-Nic
#
module "external-network-security-group" {
  source                = "Azure/network-security-group/azurerm"
  resource_group_name   = azurerm_resource_group.rg.name
  security_group_name   = format("%s-external-nsg-%s", var.prefix, random_id.id.hex)
  source_address_prefix = ["10.0.2.0/24"]
  custom_rules = [
    {
      name                   = "myhttp"
      priority               = "200"
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "tcp"
      destination_port_range = "443"
      description            = "description-myhttp"
    }
  ]
  tags = {
    environment = "dev"
    costcenter  = "terraform"
  }
}

locals {
  vnet_subnet_network_security_group_ids = concat([module.mgmt-network-security-group.network_security_group_id, module.external-network-security-group.network_security_group_id])
}
