variable location {
  description = "Resource Group Location"
  type        = string
}
variable "prefix" {
  description = "Prefix for resources created by this module"
  type        = string
  default     = "terraform-azure-bigip"
}
variable nb_nics {
  description = "Specify the number of nic interfaces"
  default     = 1
}
variable nb_public_ip {
  description = "Number of public IPs to assign corresponding to one IP per vm. Set to 0 to not assign any public IP addresses."
  default     = 1
}

variable availabilityZones {
  description = "If you want the VM placed in an Azure Availability Zone, and the Azure region you are deploying to supports it, specify the numbers of the existing Availability Zone you want to use."
  type        = list
  default     = []
}

variable az_key_vault_authentication {
  description = "The name of the resource group in which the resources will be created"
  type        = bool
  default     = true
}

variable azure_secret_rg {
  description = "The name of the resource group in which the resources will be created"
  type        = string
}

variable azure_keyvault_name {
  description = "The name of the resource group in which the resources will be created"
  type        = string
}

variable azure_keyvault_secret_name {
  description = "The name of the resource group in which the resources will be created"
  type        = string
}
