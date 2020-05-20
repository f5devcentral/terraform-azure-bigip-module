provider "azurerm" {
  version = "~>2.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "testResourceGroup"
  location = "southindia"
}

module "bigip1nic" {
  source              = "./1NIC"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_subnet_id      = module.network.vnet_subnets[0]
}


module "network" {
  source              = "Azure/network/azurerm"
  version             = "3.0.0"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_prefixes     = ["10.0.1.0/24"]
}

output "f5vm_public_name" {
  value = module.bigip1nic.public_ip_dns_name
}


// module "linuxservers" {
//   source                        = "Azure/compute/azurerm"
//   resource_group_name           = azurerm_resource_group.rg.name
//   vm_hostname                   = "mylinuxvm"
//   nb_public_ip                  = 0
//   remote_port                   = "22"
//   nb_instances                  = 2
//   vm_os_publisher               = "Canonical"
//   vm_os_offer                   = "UbuntuServer"
//   vm_os_sku                     = "18.04-LTS"
//   vnet_subnet_id                = module.network.vnet_subnets[0]
//   boot_diagnostics              = true
//   delete_os_disk_on_termination = true
//   nb_data_disk                  = 2
//   data_disk_size_gb             = 64
//   data_sa_type                  = "Premium_LRS"
//   enable_ssh_key                = true
//   vm_size                       = "Standard_D4s_v3"

//   tags = {
//     environment = "dev"
//     costcenter  = "it"
//   }

//   enable_accelerated_networking = true
// }

// module "network" {
//   source              = "Azure/network/azurerm"
//   version             = "3.0.1"
//   resource_group_name = azurerm_resource_group.rg.name
//   subnet_prefixes     = ["10.0.1.0/24"]

// }
