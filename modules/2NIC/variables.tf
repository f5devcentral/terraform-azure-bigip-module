variable resource_group_name {
  description = "The name of the resource group in which the resources will be created"
  type        = string
}
variable vnet_subnet_id {
  description = "The subnet id of the virtual network where the virtual machines will reside."
  type        = list(string)
}
// variable vnet_subnet_security_group_ids {
//   description = "The Network Security Group id of the virtual network "
//   type        = list(string)
// }

variable f5_username {
  description = "The admin username of the F5 Bigip that will be deployed"
  type        = string
  default     = "azureuser"
}

variable AllowedIPs {
  type    = list(string)
  default = ["10.0.1.20", "10.0.1.30"]
}

variable f5_instance_type {
  description = "Specifies the size of the virtual machine."
  type        = string
  default     = "Standard_DS3_v2"
}

variable f5_image_name {
  type    = string
  default = "f5-bigip-virtual-edition-25m-best-hourly"
}
variable f5_version {
  type    = string
  default = "latest"
}

variable f5_product_name {
  type    = string
  default = "f5-big-ip-best"
}

variable storage_account_type {
  description = "Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  type        = string
  default     = "Standard_LRS"
}
variable allocation_method {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  type        = string
  default     = "Dynamic"
}

variable enable_accelerated_networking {
  type        = bool
  description = "(Optional) Enable accelerated networking on Network interface"
  default     = false
}

variable enable_ssh_key {
  type        = bool
  description = "(Optional) Enable ssh key authentication in Linux virtual Machine"
  default     = false
}

variable f5_ssh_publickey {
  description = "Path to the public key to be used for ssh access to the VM.  Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash. e.g. c:/home/id_rsa.pub"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable dnsLabel {
  type = string
  //default = "ecosysf5hyd-ravi"
}

variable ADMIN_PASSWD {
  type    = string
  default = "F5Site@123"
}

variable script_name {
  type    = string
  default = "f5_onboard"
}

## Please check and update the latest DO URL from https://github.com/F5Networks/f5-declarative-onboarding/releases
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable DO_URL {
  description = "URL to download the BIG-IP Declarative Onboarding module"
  type        = string
  default     = ""
  //default     = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.13.0/f5-declarative-onboarding-1.13.0-5.noarch.rpm"
}
## Please check and update the latest AS3 URL from https://github.com/F5Networks/f5-appsvcs-extension/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable AS3_URL {
  description = "URL to download the BIG-IP Application Service Extension 3 (AS3) module"
  type        = string
  default     = ""
  //default     = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.20.0/f5-appsvcs-3.20.0-3.noarch.rpm"
}

## Please check and update the latest TS URL from https://github.com/F5Networks/f5-telemetry-streaming/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable TS_URL {
  description = "URL to download the BIG-IP Telemetry Streaming module"
  type        = string
  default     = ""
  //default     = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.12.0/f5-telemetry-1.12.0-3.noarch.rpm"
}

## Please check and update the latest FAST URL from https://github.com/F5Networks/f5-appsvcs-templates/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable FAST_URL {
  description = "URL to download the BIG-IP FAST module"
  type        = string
  default     = ""
  //default     = "https://github.com/F5Networks/f5-appsvcs-templates/releases/download/v1.1.0/f5-appsvcs-templates-1.1.0-1.noarch.rpm"
}

## Please check and update the latest Failover Extension URL from https://github.com/F5Networks/f5-cloud-failover-extension/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable CFE_URL {
  description = "URL to download the BIG-IP Cloud Failover Extension module"
  type        = string
  default     = ""
  //default     = "https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v1.3.0/f5-cloud-failover-1.3.0-0.noarch.rpm"
}

variable libs_dir {
  description = "Directory on the BIG-IP to download the A&O Toolchain into"
  default     = "/config/cloud/azure/node_modules"
  type        = string
}
variable onboard_log {
  description = "Directory on the BIG-IP to store the cloud-init logs"
  default     = "/var/log/startup-script.log"
  type        = string
}


variable "nb_instances" {
  description = "Specify the number of nic interfaces"
  default     = "3"
}


variable "public_ip_dns" {
  description = "Optional globally unique per datacenter region domain name label to apply to each public ip address. e.g. thisvar.varlocation.cloudapp.azure.com where you specify only thisvar here. This is an array of names which will pair up sequentially to the number of public ips defined in var.nb_public_ip. One name or empty string is required for every public ip. If no public ip is desired, then set this to an array with a single empty string."
  default     = ["ecosysf5hyd", "external", "internal", null]
}

variable do_rpm_filename {
  description = ""
  default     = "f5-declarative-onboarding-1.13.0-5.noarch.rpm"
  type        = string
}
variable do_version {
  description = ""
  default     = "v1.13.0"
  type        = string
}
variable as3_rpm_filename {
  description = ""
  default     = "f5-appsvcs-3.20.0-3.noarch.rpm"
  type        = string
}
variable as3_version {
  description = ""
  default     = "v3.20.0"
  type        = string
}

