
provider "azurerm" {
  version = "~>2.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
        name = "testResourceGroup"
        location = "westus"
}

resource "azurerm_network_security_group" "bigip-nsg-ext" {
  name                = "${var.dns_lable}-ext-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags = var.tags
}

resource "azurerm_network_security_group" "bigip-nsg-mgmt" {
  name                = "${var.dns_lable}-mgmt-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags = var.tags
}

resource "azurerm_public_ip" "bigip-mgmt" {
  name                = "${var.dns_lable}-mgmt-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = var.allocation_method
  domain_name_label   = var.dns_lable
  tags                = var.tags
}
