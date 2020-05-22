variable "vm_hostname" {
  description = "local name of the VM"
  default     = "myvm"
}

variable "nb_public_ip" {
  description = "Number of public IPs to assign corresponding to one IP per vm. Set to 0 to not assign any public IP addresses."
  default     = "1"
}

variable "nb_instances" {
  description = "Specify the number of nic interfaces"
  default     = "3"
}

variable "allocation_method" {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  default     = "Dynamic"
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}

variable "public_ip_dns" {
  description = "Optional globally unique per datacenter region domain name label to apply to each public ip address. e.g. thisvar.varlocation.cloudapp.azure.com where you specify only thisvar here. This is an array of names which will pair up sequentially to the number of public ips defined in var.nb_public_ip. One name or empty string is required for every public ip. If no public ip is desired, then set this to an array with a single empty string."
  default     = [null]
}

variable "enable_accelerated_networking" {
  type        = bool
  description = "(Optional) Enable accelerated networking on Network interface"
  default     = false
}

