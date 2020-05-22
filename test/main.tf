provider "azurerm" {
  version = "~>2.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "testResourceGroup2"
  location = "southindia"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet"
  address_space       = ["20.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "example" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["20.0.1.0/24"]
}

resource "azurerm_public_ip" "vm" {
  count               = var.nb_instances
  name                = "${var.vm_hostname}-pip-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = var.allocation_method
  domain_name_label   = element(var.public_ip_dns, count.index)
  tags                = var.tags
}

resource "azurerm_network_interface" "vm" {
  count                         = var.nb_instances
  name                          = "${var.vm_hostname}-nic-${count.index}"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "${var.vm_hostname}-ip-${count.index}"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = var.allocation_method
    public_ip_address_id          = length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, list("")), count.index) : ""
  }

  tags = var.tags
}

resource "azurerm_network_security_group" "vm" {
  name                = "${var.vm_hostname}-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "nicnsg" {
  count                     = var.nb_instances
  network_interface_id      = azurerm_network_interface.vm[count.index].id
  network_security_group_id = azurerm_network_security_group.vm.id
}


// resource "azurerm_virtual_machine" "f5vm01" {
//   name                         = "${var.vm_hostname}-f5vm01"
//   location                     = azurerm_resource_group.r.location
//   resource_group_name          = azurerm_resource_group.r.name
//   primary_network_interface_id = element(concat(azurerm_network_interface.vm.*.id, list("")), 0)
//   network_interface_ids        = concat(azurerm_network_interface.vm.*.id, list(""))
//   vm_size                      = var.f5_instance_type

//   # Uncomment this line to delete the OS disk automatically when deleting the VM
//   delete_os_disk_on_termination = true


//   # Uncomment this line to delete the data disks automatically when deleting the VM
//   delete_data_disks_on_termination = true

//   storage_image_reference {
//     publisher = "f5-networks"
//     offer     = var.f5_product_name
//     sku       = var.f5_image_name
//     version   = var.f5_version
//   }

//   storage_os_disk {
//     name              = "osdisk-${var.vm_hostname}-f5vm01"
//     caching           = "ReadWrite"
//     create_option     = "FromImage"
//     managed_disk_type = var.storage_account_type
//   }

//   os_profile {
//     computer_name  = "${var.vm_hostname}-f5vm01"
//     admin_username = var.f5_username
//     admin_password = var.ADMIN_PASSWD
//     #custom_data    = data.template_file.f5_bigip_onboard.rendered
//   }
//   os_profile_linux_config {
//     disable_password_authentication = var.enable_ssh_key

//     dynamic ssh_keys {
//       for_each = var.enable_ssh_key ? [var.f5_ssh_publickey] : []
//       content {
//         path     = "/home/${var.f5_username}/.ssh/authorized_keys"
//         key_data = file(var.f5_ssh_publickey)
//       }
//     }
//   }
//   plan {
//     name      = var.f5_image_name
//     publisher = "f5-networks"
//     product   = var.f5_product_name
//   }
//   tags = {
//     owner  = var.dnsLabel
//     Name   = "${var.dnsLabel}-f5vm01"
//     source = "terraform"
//   }
// }
