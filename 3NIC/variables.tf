variable "azure_rg_name" {
    type = "string"
    default = "testResourceGroup"
}
variable "f5_username" {
  description = "user of the F5 admin that will be created"
  default = "azureuser"
}
variable "azure_region" {
  type = "string"
  default = "westus"
}

variable "subnet1_public_id" {
  type = "string"
  default="/subscriptions/d31e4e54-7577-4f43-b407-bae6cc0f4f55/resourceGroups/testResourceGroup/providers/Microsoft.Network/virtualNetworks/acceptanceTestVirtualNetwork1/subnets/testsubnet"
}
variable "AllowedIPs" {
  type = list(string)
  default = ["10.0.1.20","10.0.1.30"]
}

variable "f5_instance_type" {
  type = "string"
  default = "Standard_DS3_v2"
}

variable "f5_image_name" {
  type = "string"
  default ="f5-bigip-virtual-edition-25m-best-hourly"
}
variable "f5_version" {
  type = "string"
  default = "latest"
}

variable "f5_product_name" {
  type = "string"
  default = "f5-big-ip-best"
}

variable libs_dir { 
  default = "/config/cloud/azure/node_modules" 
}
variable onboard_log { 
  default = "/var/log/startup-script.log" 
}

variable "f5_ssh_publickey" {
  type = "string"
  default="~/.ssh/id_rsa.pub"
}
variable "owner" {
  type = "string"
  default="User"
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
  type = "string"
  default = "RaviAzure@2020" 
}