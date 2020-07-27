# BIG-IP Environment
location                    = "eastus"
az_key_vault_authentication = false

# Prefix for objects being created
prefix = "terraform-azure-bigip"

azure_secret_rg            = "mykvrg"
azure_keyvault_name        = "mykv"
azure_keyvault_secret_name = "mykvsec"
availabilityZones          = []
nb_nics                    = 2
nb_public_ip               = 1
