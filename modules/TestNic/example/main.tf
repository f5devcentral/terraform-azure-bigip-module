locals {
  bigip_map = {
    "mgmt_subnet_id"            = [data.azurerm_subnet.mgmt.id]
    "mgmt_securitygroup_id"     = [module.mgmt-network-security-group.network_security_group_id]
    "external_subnet_id"        = [data.azurerm_subnet.external.id, data.azurerm_subnet.external2.id]
    "external_securitygroup_id" = [module.external-network-security-group.network_security_group_id, module.external-network-security-group.network_security_group_id]
    "internal_subnet_id"        = [data.azurerm_subnet.internal.id]
    "internal_securitygroup_id" = [module.internal-network-security-group.network_security_group_id]
  }
  total_nics = length(concat(local.bigip_map["mgmt_subnet_id"], local.bigip_map["external_subnet_id"], local.bigip_map["internal_subnet_id"]))
}

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
# Create the Network Module to associate with BIGIP
#

module "network" {
  source              = "Azure/vnet/azurerm"
  vnet_name           = format("%s-vnet-%s", var.prefix, random_id.id.hex)
  resource_group_name = azurerm_resource_group.rg.name
  //address_space       = concat([local.cidr])
  address_space   = [var.cidr]
  subnet_prefixes = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24", "10.2.4.0/24", "10.2.5.0/24"]
  //subnet_prefixes = concat([local.mgmt_cidrs, local.public_cidrs, local.private_cidrs])
  subnet_names = ["mgmt-subnet", "external-subnet", "internal-subnet", "mgmt-subnet2", "external-subnet2"]

  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}

data "azurerm_subnet" "mgmt" {
  name                 = "mgmt-subnet"
  virtual_network_name = module.network.vnet_name
  resource_group_name  = azurerm_resource_group.rg.name
}

data "azurerm_subnet" "mgmt2" {
  name                 = "mgmt-subnet2"
  virtual_network_name = module.network.vnet_name
  resource_group_name  = azurerm_resource_group.rg.name
}

data "azurerm_subnet" "external" {
  name                 = "external-subnet"
  virtual_network_name = module.network.vnet_name
  resource_group_name  = azurerm_resource_group.rg.name
}

data "azurerm_subnet" "external2" {
  name                 = "external-subnet2"
  virtual_network_name = module.network.vnet_name
  resource_group_name  = azurerm_resource_group.rg.name
}

data "azurerm_subnet" "internal" {
  name                 = "internal-subnet"
  virtual_network_name = module.network.vnet_name
  resource_group_name  = azurerm_resource_group.rg.name
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
      destination_port_range = local.total_nics > 1 ? "443" : "8443"
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

output bigip_map {
  value = local.bigip_map
  //"${subnetdata.az}:${subnetdata.subnet_type}:${subnetdata.num}" => subnetdata
}

output total_nics {
  value = local.total_nics
  //"${subnetdata.az}:${subnetdata.subnet_type}:${subnetdata.num}" => subnetdata
}

#
# Create the 1Nic BIGIP
#
module bigip {
  source              = "../"
  dnsLabel            = format("%s-%s", var.prefix, random_id.id.hex)
  resource_group_name = azurerm_resource_group.rg.name
  bigip_map           = local.bigip_map
  mgmt_publicip       = true
  availabilityZones   = var.availabilityZones
}