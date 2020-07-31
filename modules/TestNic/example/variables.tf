variable prefix {
  description = "Prefix for resources created by this module"
  type        = string
  //default     = "tf-azure-bigip"
}
variable location {
  description = "Azure Region/location for Resources"
  type        = string
}

variable cidr {
  description = "Azure VPC CIDR"
  type        = string
  //default     = "10.0.0.0/16"
}

variable allowed_mgmt_cidr {
  description = "CIDR of allowed IPs for the BIG-IP management interface"
  type        = list(string)
  //default = ["10.0.1.20", "10.0.1.30"]
}

variable allowed_app_cidr {
  description = "CIDR of allowed IPs for the BIG-IP Virtual Servers"
  type        = list(string)
  //default     = "0.0.0.0/0"
}
variable nb_nics {
  description = "Specify the number of nic interfaces"
  default     = 3
}


variable availabilityZones {
  description = "If you want the VM placed in an Azure Availability Zone, and the Azure region you are deploying to supports it, specify the numbers of the existing Availability Zone you want to use."
  type        = list
  default     = [1]
}