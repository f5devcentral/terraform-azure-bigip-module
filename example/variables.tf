variable prefix {
  description = "Prefix for resources created by this module"
  type        = string
  default     = "tf-azure-bigip"
}
variable location {
  description = "Azure Region/location for Resources"
  type        = string
}

variable cidr {
  description = "Azure VPC CIDR"
  type        = string
  default     = "10.2.0.0/16"
}

variable allowed_mgmt_cidr {
  description = "CIDR of allowed IPs for the BIG-IP management interface"
  type        = list(string)
  default = ["10.0.1.20", "10.0.1.30"]
}

variable allowed_app_cidr {
  description = "CIDR of allowed IPs for the BIG-IP Virtual Servers"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable availabilityZones {
  description = "If you want the VM placed in an Azure Availability Zone, and the Azure region you are deploying to supports it, specify the numbers of the existing Availability Zone you want to use."
  type        = list
  default     = [1]
}


variable AllowedIPs {
  type    = list(string)
  default = ["10.0.1.20", "10.0.1.30"]
}



variable azure_secret_rg {
  description = "The name of the resource group in which the Azure Key Vault exists"
  type        = string
  default     = ""
}

variable az_key_vault_authentication {
  description = "Whether to use key vault to pass authentication"
  type        = bool
  default     = false
}

variable azure_keyvault_name {
  description = "The name of the Azure Key Vault to use"
  type        = string
  default     = ""
}

variable azure_keyvault_secret_name {
  description = "The name of the Azure Key Vault secret containing the password"
  type        = string
  default     = ""
}
