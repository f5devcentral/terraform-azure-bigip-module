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

data "azurerm_client_config" "current" {
}

resource azurerm_resource_group rgkeyvault {
  name     = format("%s-%s", var.azure_secret_rg, random_id.id.hex)
  location = var.location
}

resource random_id server {
  keepers = {
    ami_id = 1
  }
  byte_length = 8
}

resource azurerm_key_vault azkv {
  name                        = format("%s-%s", var.azure_keyvault_name, random_id.server.hex)
  location                    = azurerm_resource_group.rgkeyvault.location
  resource_group_name         = azurerm_resource_group.rgkeyvault.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = true
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get", "list", "update", "create", "import", "delete", "recover", "backup", "restore",
    ]

    secret_permissions = [
      "get", "list", "delete", "recover", "backup", "restore", "set",
    ]

    storage_permissions = [
      "get",
    ]
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = {
    environment = "Testing"
  }
}

#
# Create random password for BIG-IP
#
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = " #%*+,-./:=?@[]^_~"
}

resource azurerm_key_vault_secret azkvsec {
  name         = format("%s-%s", var.azure_keyvault_secret_name, random_id.server.hex)
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.azkv.id

  tags = {
    environment = "Testing"
  }
}

#
# Create the 1Nic BIGIP
#
module bigip {
  source                         = "../../"
  dnsLabel                       = format("%s-%s", var.prefix, random_id.id.hex)
  resource_group_name            = azurerm_resource_group.rg.name
  vnet_subnet_id                 = module.network.vnet_subnets
  vnet_subnet_security_group_ids = [module.network-security-group.network_security_group_id]
  availabilityZones              = var.availabilityZones
  az_key_vault_authentication    = var.az_key_vault_authentication
  azure_secret_rg                = var.az_key_vault_authentication ? azurerm_resource_group.rgkeyvault.name : ""
  azure_keyvault_name            = var.az_key_vault_authentication ? azurerm_key_vault.azkv.name : ""
  azure_keyvault_secret_name     = var.az_key_vault_authentication ? azurerm_key_vault_secret.azkvsec.name : ""
  nb_nics                        = var.nb_nics
  nb_public_ip                   = var.nb_public_ip
}

resource "local_file" "DOjson1" {
  content  = module.bigip.onboard_do
  filename = "DO.json"
  //depends_on = [azurerm_virtual_machine.f5vm01]
}

// resource "local_file" "DOjson2" {
//   count      = var.nb_nics == 2 ? 1 : 0
//   content    = "${data.template_file.clustermemberDO2[0].rendered}"
//   filename   = "${path.module}/DO.json"
//   depends_on = [azurerm_virtual_machine.f5vm01]
// }
// resource "local_file" "DOjson3" {
//   count      = var.nb_nics == 3 ? 1 : 0 
//   content    = "${data.template_file.clustermemberDO3[0].rendered}"
//   filename   = "${path.module}/DO.json"
//   depends_on = [azurerm_virtual_machine.f5vm01]
// }



#
# Create the Network Module to associate with BIGIP
#
module network {
  source              = "Azure/network/azurerm"
  version             = "3.1.1"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["mgmt-subnet"]
}

module "network-security-group" {
  source                = "Azure/network-security-group/azurerm"
  resource_group_name   = azurerm_resource_group.rg.name
  security_group_name   = format("%s-nsg-%s", var.prefix, random_id.id.hex)
  source_address_prefix = ["10.0.1.0/24"]
  predefined_rules = [
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
      destination_port_range = var.nb_nics > 1 ? "443" : "8443"
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

