# BIG-IP Environment
location                    = "southindia"
az_key_vault_authentication = true

# Prefix for objects being created
prefix = "terraform-azure-bigip"

azure_keyvault_name        = "mykv"
azure_keyvault_secret_name = "mykvsec"
availabilityZones          = []
nb_nics                    = 1
nb_public_ip               = 1
