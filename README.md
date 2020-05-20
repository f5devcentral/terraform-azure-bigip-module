## Deploys F5 BIGIP to your provided VNet/Network

This Terraform module deploys F5 BIGIP-1Nic in Azure with the following characteristics:

- VM nics attached to a single virtual network subnet of your choice (new or existing) via `var.vnet_subnet_id`.
- Control the number of Public IP addresses assigned to VMs via `var.nb_public_ip`. Create and attach one Public IP per VM up to the number of VMs or create NO public IPs via setting `var.nb_public_ip` to `0`.

## Simple Usage

This contains the bare minimum options to be configured for the F5 BIGIP to be provisioned.  The entire code block provisions F5 BIGIP VM, but feel free to delete one or the other and corresponding outputs. The outputs are also not necessary to provision, but included to make it convenient to know the address to connect to the VMs after provisioning completes.

The F5 BIGIP will use the ssh key found in the default location `~/.ssh/id_rsa.pub`.

```hcl

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

```