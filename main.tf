terraform {
  required_version = "~> 0.13"
  required_providers {
      azurerm = {
         source = "hashicorp/azurerm"
	 version = "~>2.28.0"
       }
       random = {
         source = "hashicorp/random"
         version = "~>2.3.0"
       }
       template = {
         source = "hashicorp/template"
         version = "~>2.1.2"
       }
       null = {
         source = "hashicorp/null"
         version = "~>2.1.2"
      }
 } 
}

locals {
  bigip_map = {
    "mgmt_subnet_ids"            = var.mgmt_subnet_ids
    "mgmt_securitygroup_ids"     = var.mgmt_securitygroup_ids
    "external_subnet_ids"        = var.external_subnet_ids
    "external_securitygroup_ids" = var.external_securitygroup_ids
    "internal_subnet_ids"        = var.internal_subnet_ids
    "internal_securitygroup_ids" = var.internal_securitygroup_ids
  }

  mgmt_public_subnet_id = [
    for subnet in local.bigip_map["mgmt_subnet_ids"] :
    subnet["subnet_id"]
    if subnet["public_ip"] == true
  ]
  mgmt_public_index = [
    for index, subnet in local.bigip_map["mgmt_subnet_ids"] :
    index
    if subnet["public_ip"] == true
  ]
  mgmt_public_security_id = [
    for i in local.mgmt_public_index : local.bigip_map["mgmt_securitygroup_ids"][i]
  ]
  mgmt_private_subnet_id = [
    for subnet in local.bigip_map["mgmt_subnet_ids"] :
    subnet["subnet_id"]
    if subnet["public_ip"] == false
  ]
  mgmt_private_index = [
    for index, subnet in local.bigip_map["mgmt_subnet_ids"] :
    index
    if subnet["public_ip"] == false
  ]
  mgmt_private_security_id = [
    for i in local.external_private_index : local.bigip_map["mgmt_securitygroup_ids"][i]
  ]
  external_public_subnet_id = [
    for subnet in local.bigip_map["external_subnet_ids"] :
    subnet["subnet_id"]
    if subnet["public_ip"] == true
  ]
  external_public_index = [
    for index, subnet in local.bigip_map["external_subnet_ids"] :
    index
    if subnet["public_ip"] == true
  ]
  external_public_security_id = [
    for i in local.external_public_index : local.bigip_map["external_securitygroup_ids"][i]
  ]
  external_private_subnet_id = [
    for subnet in local.bigip_map["external_subnet_ids"] :
    subnet["subnet_id"]
    if subnet["public_ip"] == false
  ]
  external_private_index = [
    for index, subnet in local.bigip_map["external_subnet_ids"] :
    index
    if subnet["public_ip"] == false
  ]
  external_private_security_id = [
    for i in local.external_private_index : local.bigip_map["external_securitygroup_ids"][i]
  ]
  internal_public_subnet_id = [
    for subnet in local.bigip_map["internal_subnet_ids"] :
    subnet["subnet_id"]
    if subnet["public_ip"] == true
  ]
  internal_public_index = [
    for index, subnet in local.bigip_map["internal_subnet_ids"] :
    index
    if subnet["public_ip"] == true
  ]
  internal_public_security_id = [
    for i in local.internal_public_index : local.bigip_map["internal_securitygroup_ids"][i]
  ]
  internal_private_subnet_id = [
    for subnet in local.bigip_map["internal_subnet_ids"] :
    subnet["subnet_id"]
    if subnet["public_ip"] == false
  ]
  internal_private_index = [
    for index, subnet in local.bigip_map["internal_subnet_ids"] :
    index
    if subnet["public_ip"] == false
  ]
  internal_private_security_id = [
    for i in local.internal_private_index : local.bigip_map["internal_securitygroup_ids"][i]
  ]
  total_nics  = length(concat(local.mgmt_public_subnet_id, local.mgmt_private_subnet_id, local.external_public_subnet_id, local.external_private_subnet_id, local.internal_public_subnet_id, local.internal_private_subnet_id))
  vlan_list   = concat(local.external_public_subnet_id, local.external_private_subnet_id, local.internal_public_subnet_id, local.internal_private_subnet_id)
  selfip_list = concat(azurerm_network_interface.external_nic.*.private_ip_address, azurerm_network_interface.external_public_nic.*.private_ip_address, azurerm_network_interface.internal_nic.*.private_ip_address)
  instance_prefix = format("%s-%s", var.prefix, random_id.module_id.hex)
  gw_bytes_nic = local.total_nics > 1 ? "${element(split("/",local.selfip_list[0]), 0 )}" : ""
}

#
# Create a random id
#
resource "random_id" "module_id" {
  byte_length = 2
}

data "azurerm_resource_group" "bigiprg" {
  name = var.resource_group_name
}

data "azurerm_resource_group" "rg_keyvault" {
  name  = var.azure_secret_rg
  count = var.az_key_vault_authentication ? 1 : 0
}

data "azurerm_key_vault" "keyvault" {
  count               = var.az_key_vault_authentication ? 1 : 0
  name                = var.azure_keyvault_name
  resource_group_name = data.azurerm_resource_group.rg_keyvault[count.index].name
}

data "azurerm_key_vault_secret" "bigip_admin_password" {
  count        = var.az_key_vault_authentication ? 1 : 0
  name         = var.azure_keyvault_secret_name
  key_vault_id = data.azurerm_key_vault.keyvault[count.index].id
}

#
# Create random password for BIG-IP
#
resource random_string password {
  length      = 16
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  special     = false
}

data "template_file" "init_file" {
  template = "${file("${path.module}/${var.script_name}.tpl")}"
  vars = {
    onboard_log    = var.onboard_log
    libs_dir       = var.libs_dir
    DO_URL         = var.doPackageUrl
    AS3_URL        = var.as3PackageUrl
    TS_URL         = var.tsPackageUrl
    FAST_URL       = var.fastPackageUrl
    CFE_URL        = var.cfePackageUrl
    bigip_username = var.f5_username
    bigip_password = var.az_key_vault_authentication ? data.azurerm_key_vault_secret.bigip_admin_password[0].value : random_string.password.result
  }
}

# Create a Public IP for bigip
resource "azurerm_public_ip" "mgmt_public_ip" {
  count               = length(local.bigip_map["mgmt_subnet_ids"])
  name                = "${local.instance_prefix}-pip-mgmt-${count.index}"
  location            = data.azurerm_resource_group.bigiprg.location
  resource_group_name = data.azurerm_resource_group.bigiprg.name
  domain_name_label   = format("%s-mgmt-%s", local.instance_prefix, count.index)
  allocation_method   = "Static"   # Static is required due to the use of the Standard sku
  sku                 = "Standard" # the Standard sku is required due to the use of availability zones
  zones               = var.availabilityZones
  tags = {
    Name   = "${local.instance_prefix}-pip-mgmt-${count.index}"
    source = "terraform"
  }
}

resource "azurerm_public_ip" "external_public_ip" {
  count               = length(local.external_public_subnet_id)
  name                = "${local.instance_prefix}-pip-ext-${count.index}"
  location            = data.azurerm_resource_group.bigiprg.location
  resource_group_name = data.azurerm_resource_group.bigiprg.name
  //allocation_method   = var.allocation_method
  //domain_name_label   = element(var.public_ip_dns, count.index)
  domain_name_label = format("%s-ext-%s", local.instance_prefix, count.index)
  allocation_method = "Static"   # Static is required due to the use of the Standard sku
  sku               = "Standard" # the Standard sku is required due to the use of availability zones
  zones             = var.availabilityZones
  tags = {
    Name   = "${local.instance_prefix}-pip-ext-${count.index}"
    source = "terraform"
  }
}

# Deploy BIG-IP with N-Nic interface 
resource "azurerm_network_interface" "mgmt_nic" {
  count               = length(local.bigip_map["mgmt_subnet_ids"])
  name                = "${local.instance_prefix}-mgmt-nic-${count.index}"
  location            = data.azurerm_resource_group.bigiprg.location
  resource_group_name = data.azurerm_resource_group.bigiprg.name
  //enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "${local.instance_prefix}-mgmt-ip-${count.index}"
    subnet_id                     = local.bigip_map["mgmt_subnet_ids"][count.index]["subnet_id"]
    private_ip_address_allocation = var.allocation_method
    public_ip_address_id          = local.bigip_map["mgmt_subnet_ids"][count.index]["public_ip"] ? azurerm_public_ip.mgmt_public_ip[count.index].id : ""
  }
  tags = {
    Name   = "${local.instance_prefix}-mgmt-nic-${count.index}"
    source = "terraform"
  }
}

resource "azurerm_network_interface" "external_nic" {
  count               = length(local.external_private_subnet_id)
  name                = "${local.instance_prefix}-ext-nic-${count.index}"
  location            = data.azurerm_resource_group.bigiprg.location
  resource_group_name = data.azurerm_resource_group.bigiprg.name
  //enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "${local.instance_prefix}-ext-ip-${count.index}"
    subnet_id                     = local.external_private_subnet_id[count.index]
    private_ip_address_allocation = var.allocation_method
    //public_ip_address_id          = length(azurerm_public_ip.mgmt_public_ip.*.id) > count.index ? azurerm_public_ip.mgmt_public_ip[count.index].id : ""
  }
  tags = {
    Name   = "${local.instance_prefix}-ext-nic-${count.index}"
    source = "terraform"
  }
}


resource "azurerm_network_interface" "external_public_nic" {
  count               = length(local.external_public_subnet_id)
  name                = "${local.instance_prefix}-ext-nic-public-${count.index}"
  location            = data.azurerm_resource_group.bigiprg.location
  resource_group_name = data.azurerm_resource_group.bigiprg.name
  //enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "${local.instance_prefix}-ext-public-ip-${count.index}"
    subnet_id                     = local.external_public_subnet_id[count.index]
    private_ip_address_allocation = var.allocation_method
    public_ip_address_id          = azurerm_public_ip.external_public_ip[count.index].id
  }
  tags = {
    Name   = "${local.instance_prefix}-ext-public-nic-${count.index}"
    source = "terraform"
  }
}

resource "azurerm_network_interface" "internal_nic" {
  count               = length(local.internal_private_subnet_id)
  name                = "${local.instance_prefix}-int-nic${count.index}"
  location            = data.azurerm_resource_group.bigiprg.location
  resource_group_name = data.azurerm_resource_group.bigiprg.name
  //enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "${local.instance_prefix}-int-ip-${count.index}"
    subnet_id                     = local.internal_private_subnet_id[count.index]
    private_ip_address_allocation = var.allocation_method
    //public_ip_address_id          = length(azurerm_public_ip.mgmt_public_ip.*.id) > count.index ? azurerm_public_ip.mgmt_public_ip[count.index].id : ""
  }
  tags = {
    Name   = "${local.instance_prefix}-internal-nic-${count.index}"
    source = "terraform"
  }
}

resource "azurerm_network_interface_security_group_association" "mgmt_security" {
  count                = length(local.bigip_map["mgmt_securitygroup_ids"])
  network_interface_id = azurerm_network_interface.mgmt_nic[count.index].id
  //network_security_group_id = azurerm_network_security_group.bigip_sg.id
  network_security_group_id = local.bigip_map["mgmt_securitygroup_ids"][count.index]
}

resource "azurerm_network_interface_security_group_association" "external_security" {
  count                = length(local.external_private_security_id)
  network_interface_id = azurerm_network_interface.external_nic[count.index].id
  //network_security_group_id = azurerm_network_security_group.bigip_sg.id
  network_security_group_id = local.external_private_security_id[count.index]
}

resource "azurerm_network_interface_security_group_association" "external_public_security" {
  count                = length(local.external_public_security_id)
  network_interface_id = azurerm_network_interface.external_public_nic[count.index].id
  //network_security_group_id = azurerm_network_security_group.bigip_sg.id
  network_security_group_id = local.external_public_security_id[count.index]
}

resource "azurerm_network_interface_security_group_association" "internal_security" {
  count                = length(local.internal_private_security_id)
  network_interface_id = azurerm_network_interface.internal_nic[count.index].id
  //network_security_group_id = azurerm_network_security_group.bigip_sg.id
  network_security_group_id = local.internal_private_security_id[count.index]
}


# Create F5 BIGIP1
resource "azurerm_virtual_machine" "f5vm01" {
  name                         = "${local.instance_prefix}-f5vm01"
  location                     = data.azurerm_resource_group.bigiprg.location
  resource_group_name          = data.azurerm_resource_group.bigiprg.name
  primary_network_interface_id = element(azurerm_network_interface.mgmt_nic.*.id, 0)
  network_interface_ids        = concat(azurerm_network_interface.mgmt_nic.*.id, azurerm_network_interface.external_nic.*.id, azurerm_network_interface.external_public_nic.*.id, azurerm_network_interface.internal_nic.*.id)
  vm_size                      = var.f5_instance_type

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "f5-networks"
    offer     = var.f5_product_name
    sku       = var.f5_image_name
    version   = var.f5_version
  }

  storage_os_disk {
    name              = "${local.instance_prefix}-osdisk-f5vm01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.storage_account_type
  }

  os_profile {
    computer_name  = "${local.instance_prefix}-f5vm01"
    admin_username = var.f5_username
    admin_password = var.az_key_vault_authentication ? data.azurerm_key_vault_secret.bigip_admin_password[0].value : random_string.password.result
    #custom_data    = data.template_file.f5_bigip_onboard.rendered
  }
  os_profile_linux_config {
    disable_password_authentication = var.enable_ssh_key

    dynamic ssh_keys {
      for_each = var.enable_ssh_key ? [var.f5_ssh_publickey] : []
      content {
        path     = "/home/${var.f5_username}/.ssh/authorized_keys"
        key_data = file(var.f5_ssh_publickey)
      }
    }
  }
  plan {
    name      = var.f5_image_name
    publisher = "f5-networks"
    product   = var.f5_product_name
  }
  zones = var.availabilityZones
  tags = {
    Name   = "${local.instance_prefix}-f5vm01"
    source = "terraform"
  }
  depends_on = [azurerm_network_interface_security_group_association.mgmt_security, azurerm_network_interface_security_group_association.internal_security, azurerm_network_interface_security_group_association.external_security, azurerm_network_interface_security_group_association.external_public_security]
}

## ..:: Run Startup Script ::..
resource "azurerm_virtual_machine_extension" "vmext" {

  name               = "${local.instance_prefix}-vmext1"
  depends_on         = [azurerm_virtual_machine.f5vm01]
  virtual_machine_id = azurerm_virtual_machine.f5vm01.id

  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = <<PROT
  {
    "script": "${base64encode(data.template_file.init_file.rendered)}"
  }
  PROT
}

# Getting Public IP Assigned to BIGIP
data "azurerm_public_ip" "f5vm01mgmtpip" {
  //   //count               = var.nb_public_ip
  name                = azurerm_public_ip.mgmt_public_ip[0].name
  resource_group_name = data.azurerm_resource_group.bigiprg.name
  depends_on          = [azurerm_virtual_machine.f5vm01, azurerm_virtual_machine_extension.vmext,azurerm_public_ip.mgmt_public_ip[0]]
}

data "template_file" "clustermemberDO1" {
  count    = local.total_nics == 1 ? 1 : 0
  template = "${file("${path.module}/onboard_do_1nic.tpl")}"
  vars = {
    hostname      = data.azurerm_public_ip.f5vm01mgmtpip.fqdn
    name_servers  = join(",", formatlist("\"%s\"", ["168.63.129.16"]))
    search_domain = "f5.com"
    ntp_servers   = join(",", formatlist("\"%s\"", ["0.pool.ntp.org", "1.pool.ntp.org", "2.pool.ntp.org"]))
  }
}

data "template_file" "clustermemberDO2" {
  count    = local.total_nics == 2 ? 1 : 0
  template = file("${path.module}/onboard_do_2nic.tpl")
  vars = {
    hostname      = data.azurerm_public_ip.f5vm01mgmtpip.fqdn
    name_servers  = join(",", formatlist("\"%s\"", ["168.63.129.16"]))
    search_domain = "f5.com"
    ntp_servers   = join(",", formatlist("\"%s\"", ["0.pool.ntp.org", "1.pool.ntp.org", "2.pool.ntp.org"]))
    vlan-name     = "${element(split("/", local.vlan_list[0]), length(split("/", local.vlan_list[0])) - 1)}"
    self-ip       = local.selfip_list[0]
    gateway       = join(".", concat(slice(split(".",local.gw_bytes_nic),0,3),[1]) )
  }
  depends_on = [azurerm_network_interface.external_nic, azurerm_network_interface.external_public_nic, azurerm_network_interface.internal_nic]
}

data "template_file" "clustermemberDO3" {
  count    = local.total_nics == 3 ? 1 : 0
  template = file("${path.module}/onboard_do_3nic.tpl")
  vars = {
    hostname      = data.azurerm_public_ip.f5vm01mgmtpip.fqdn
    name_servers  = join(",", formatlist("\"%s\"", ["168.63.129.16"]))
    search_domain = "f5.com"
    ntp_servers   = join(",", formatlist("\"%s\"", ["0.pool.ntp.org", "1.pool.ntp.org", "2.pool.ntp.org"]))
    vlan-name1    = "${element(split("/", local.vlan_list[0]), length(split("/", local.vlan_list[0])) - 1)}"
    self-ip1      = local.selfip_list[0]
    vlan-name2    = "${element(split("/", local.vlan_list[1]), length(split("/", local.vlan_list[1])) - 1)}"
    self-ip2      = local.selfip_list[1]
    gateway       = join(".", concat(slice(split(".",local.gw_bytes_nic),0,3),[1]) )
  }
  depends_on = [azurerm_network_interface.external_nic, azurerm_network_interface.external_public_nic, azurerm_network_interface.internal_nic]
}
