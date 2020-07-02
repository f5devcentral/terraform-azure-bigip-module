data "azurerm_resource_group" "bigiprg" {
  name = var.resource_group_name
}

data "template_file" "init_file" {

  template = "${file("${path.module}/${var.script_name}.tpl")}"
  vars = {
    onboard_log = var.onboard_log
    libs_dir    = var.libs_dir
    DO_URL      = var.doPackageUrl
    AS3_URL     = var.as3PackageUrl
    TS_URL      = var.tsPackageUrl
    FAST_URL    = var.fastPackageUrl
    CFE_URL     = var.cfePackageUrl
  }
}

# Create a Public IP for bigip
resource "azurerm_public_ip" "mgmt_public_ip" {
  count               = var.nb_public_ip
  name                = "${var.dnsLabel}-pip-${count.index}"
  location            = data.azurerm_resource_group.bigiprg.location
  resource_group_name = data.azurerm_resource_group.bigiprg.name
  allocation_method   = var.allocation_method
  domain_name_label   = element(var.public_ip_dns, count.index)

  tags = {
    Name   = "${var.dnsLabel}-pip-${count.index}"
    owner  = var.dnsLabel
    source = "terraform"
  }
}

# Create the 1nic interface for BIG-IP 01
resource "azurerm_network_interface" "mgmt_nic" {
  count               = var.nb_nics
  name                = "${var.dnsLabel}-nic-${count.index}"
  location            = data.azurerm_resource_group.bigiprg.location
  resource_group_name = data.azurerm_resource_group.bigiprg.name
  //enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "${var.dnsLabel}-ip-${count.index}"
    subnet_id                     = var.vnet_subnet_id[count.index]
    private_ip_address_allocation = var.allocation_method
    public_ip_address_id          = length(azurerm_public_ip.mgmt_public_ip.*.id) > count.index ? azurerm_public_ip.mgmt_public_ip[count.index].id : ""
  }
  tags = {
    owner  = var.dnsLabel
    Name   = "${var.dnsLabel}-nic-${count.index}"
    source = "terraform"
  }
}

resource "azurerm_network_interface_security_group_association" "nicnsg" {
  count                = var.nb_nics
  network_interface_id = azurerm_network_interface.mgmt_nic[count.index].id
  //network_security_group_id = azurerm_network_security_group.bigip_sg.id
  network_security_group_id = var.vnet_subnet_security_group_ids[count.index]
}


# Create F5 BIGIP1
resource "azurerm_virtual_machine" "f5vm01" {
  name                         = "${var.dnsLabel}-f5vm01"
  location                     = data.azurerm_resource_group.bigiprg.location
  resource_group_name          = data.azurerm_resource_group.bigiprg.name
  primary_network_interface_id = element(azurerm_network_interface.mgmt_nic.*.id, 0)
  network_interface_ids        = azurerm_network_interface.mgmt_nic.*.id
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
    name              = "${var.dnsLabel}-osdisk-f5vm01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.storage_account_type
  }

  os_profile {
    computer_name  = "${var.dnsLabel}-f5vm01"
    admin_username = var.f5_username
    admin_password = var.ADMIN_PASSWD
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
  tags = {
    owner  = var.dnsLabel
    Name   = "${var.dnsLabel}-f5vm01"
    source = "terraform"
  }
  depends_on = [azurerm_network_interface_security_group_association.nicnsg]
}

## ..:: Run Startup Script ::..
resource "azurerm_virtual_machine_extension" "vmext" {

  name               = "${var.dnsLabel}-vmext1"
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

#Getting Public IP Assigned to BIGIP
data "azurerm_public_ip" "f5vm01mgmtpip" {
  //count               = var.nb_public_ip
  name                = azurerm_public_ip.mgmt_public_ip[0].name
  resource_group_name = data.azurerm_resource_group.bigiprg.name
  depends_on          = [azurerm_virtual_machine.f5vm01]
}
