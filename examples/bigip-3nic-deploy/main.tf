provider "azurerm" {
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
# Create BIGIP with specified no. of Nics
#
module "bigip" {
  source                         = "../../"
  dnsLabel                       = format("%s-%s", var.prefix, random_id.id.hex)
  resource_group_name            = azurerm_resource_group.rg.name
  vnet_subnet_id                 = module.network.vnet_subnets
  vnet_subnet_security_group_ids = local.vnet_subnet_network_security_group_ids
  availabilityZones              = var.availabilityZones
  nb_nics                        = var.nb_nics
  nb_public_ip                   = var.nb_public_ip
}

#
# Create the Network Module to associate with BIGIP
#
module "network" {
  source              = "Azure/network/azurerm"
  version             = "3.1.1"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
  subnet_names        = ["mgmt-subnet", "external-subnet", "internal-subnet", "private-subnet"]
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
      name                   = "Allow_Https"
      priority               = "200"
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "tcp"
      destination_port_range = var.nb_nics > 1 ? "443" : "8443"
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
      destination_port_range = "8080"
      description            = "description-myhttp"
    }
  ]
  tags = {
    environment = "dev"
    costcenter  = "terraform"
  }
}

#
# Create the Network Security group Module to associate with BIGIP-Internal-Nic
#
module "internal-network-security-group" {
  source                = "Azure/network-security-group/azurerm"
  resource_group_name   = azurerm_resource_group.rg.name
  security_group_name   = format("%s-internal-nsg-%s", var.prefix, random_id.id.hex)
  source_address_prefix = ["10.0.3.0/24"]
  tags = {
    environment = "dev"
    costcenter  = "terraform"
  }
}

locals {
  vnet_subnet_network_security_group_ids = concat([module.mgmt-network-security-group.network_security_group_id, module.external-network-security-group.network_security_group_id, module.internal-network-security-group.network_security_group_id])
}
