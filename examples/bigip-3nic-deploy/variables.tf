variable location {
  description = "Resource Group Location"
  type        = string
}

variable prefix {
  description = "Prefix for resources created by this module"
  type        = string
}
variable nb_nics {
  description = "Specify the number of nic interfaces"
}
variable nb_public_ip {
  description = "Number of public IPs to assign corresponding to one IP per vm. Set to 0 to not assign any public IP addresses."
}
variable availabilityZones {
  description = "If you want the VM placed in an Azure Availability Zone, and the Azure region you are deploying to supports it, specify the numbers of the existing Availability Zone you want to use."
  type        = list
}

variable az_key_vault_authentication {
  description = "Type of Authentication [Keyvault/Random generated password] for BIGIP Authentication,If this az_key_vault_authentication set to true, keyvault authentication will be used"
  type        = bool
}

variable azure_secret_rg {
  description = "The name of the resource group for azure keyvault"
  type        = string
}

variable azure_keyvault_name {
  description = "The name of the azure keyvault"
  type        = string
}

variable azure_keyvault_secret_name {
  description = "The name of the azure keyvault secret name"
  type        = string
}

