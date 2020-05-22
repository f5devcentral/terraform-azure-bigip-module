variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  type        = "string"
}
variable "vnet_subnet_id" {
  description = "The subnet id of the virtual network where the virtual machines will reside."
}

variable "f5_username" {
  description = "The admin username of the F5 Bigip that will be deployed"
  default     = "azureuser"
}

variable "AllowedIPs" {
  type    = list(string)
  default = ["10.0.1.20", "10.0.1.30"]
}

variable "f5_instance_type" {
  type    = "string"
  default = "Standard_DS3_v2"
}

variable "f5_image_name" {
  type    = "string"
  default = "f5-bigip-virtual-edition-25m-best-hourly"
}
variable "f5_version" {
  type    = "string"
  default = "latest"
}

variable "f5_product_name" {
  type    = "string"
  default = "f5-big-ip-best"
}

variable libs_dir {
  default = "/config/cloud/azure/node_modules"
}
variable onboard_log {
  default = "/var/log/startup-script.log"
}

variable "allocation_method" {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  default     = "Dynamic"
}

variable "f5_ssh_publickey" {
  type    = "string"
  default = "~/.ssh/id_rsa.pub"
}
variable "dnsLabel" {
  type    = "string"
  default = "ecosysf5hyd"
}

// variable "AS3_URL" { 
//   type = "string"
// }
// variable "DO_URL" { 
//   type = "string"
// }

// variable "TS_URL" { 
//   type = "string"
// }

variable "ADMIN_PASSWD" {
  type    = "string"
  default = "RaviAzure@2020"
}