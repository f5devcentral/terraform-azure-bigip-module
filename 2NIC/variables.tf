variable "nb_instances" {
  description = "Specify the number of vm instances"
  default     = "1"
}

variable "dns_lable" {
  description = "local name of the VM"
  default     = "ecosysf5hyd"
}
variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}

variable "allocation_method" {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  default     = "Dynamic"
}