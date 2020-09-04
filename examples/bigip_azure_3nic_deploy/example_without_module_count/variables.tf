variable prefix {
  description = "Prefix for resources created by this module"
  type        = string
  default     = "tf-azure-bigip"
}

variable location {}

variable cidr {
  description = "Azure VPC CIDR"
  type        = string
  default     = "10.2.0.0/16"
}


variable availabilityZones {
  description = "If you want the VM placed in an Azure Availability Zone, and the Azure region you are deploying to supports it, specify the numbers of the existing Availability Zone you want to use."
  type        = list
  default     = [1]
}


variable AllowedIPs {}




