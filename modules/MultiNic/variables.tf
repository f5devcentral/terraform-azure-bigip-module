variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  type        = string
}
variable "vnet_subnet_id" {
  description = "The subnet id of the virtual network where the virtual machines will reside."
  type        = list
  default     = []
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
  description = "Specifies the size of the virtual machine."
  type        = string
  default     = "Standard_DS3_v2"
}

variable "f5_image_name" {
  type    = string
  default = "f5-bigip-virtual-edition-25m-best-hourly"
}
variable "f5_version" {
  type    = string
  default = "latest"
}

variable "f5_product_name" {
  type    = string
  default = "f5-big-ip-best"
}

variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  default     = "Standard_LRS"
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

variable "enable_accelerated_networking" {
  type        = bool
  description = "(Optional) Enable accelerated networking on Network interface"
  default     = false
}

variable "enable_ssh_key" {
  type        = bool
  description = "(Optional) Enable ssh key authentication in Linux virtual Machine"
  default     = true
}

variable "f5_ssh_publickey" {
  description = "Path to the public key to be used for ssh access to the VM.  Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash. e.g. c:/home/id_rsa.pub"
  default     = "~/.ssh/id_rsa.pub"
}

variable "dnsLabel" {
  type    = string
  default = "ecosysf5hyd"
}
variable "nb_nics" {
  description = "Specify the number of nic interfaces"
  default     = "3"
}
variable "nb_public_ip" {
  description = "Number of public IPs to assign corresponding to one IP per vm. Set to 0 to not assign any public IP addresses."
  default     = "1"
}


// variable "AS3_URL" { 
//   type = string
// }
// variable "DO_URL" { 
//   type = string
// }

// variable "TS_URL" { 
//   type = string
// }

variable "ADMIN_PASSWD" {
  type    = string
  default = "RaviAzure@2020"
}

variable "public_ip_dns" {
  description = "Optional globally unique per datacenter region domain name label to apply to each public ip address. e.g. thisvar.varlocation.cloudapp.azure.com where you specify only thisvar here. This is an array of names which will pair up sequentially to the number of public ips defined in var.nb_public_ip. One name or empty string is required for every public ip. If no public ip is desired, then set this to an array with a single empty string."
  default     = ["ecosysf5hyd", "external", "internal", null]
}
