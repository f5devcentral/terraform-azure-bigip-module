## Deploys F5 BIG-IP Azure Cloud

This Terraform module deploys 3-NIC BIG-IP in Azure with the following characteristics:

BIG-IP 3 Nic with management, external, internal interfaces associated with user provided subnet and security-group
  
A random generated password for login to BIG-IP ( Default value of az_key_vault_authentication is false )  

## Example Usage

Below are the input parameters required for 1 NIC bigip module to deploy in AZURE

```
Example 3-NIC Deployment

module bigip {
  source                    = "../../"
  dnsLabel                  = "bigip-azure-3nic"
  resource_group_name       = "testbigip"
  mgmt_subnet_id            = [{"subnet_id" = "subnet_id_mgmt" , "public_ip" = true}]
  mgmt_securitygroup_id     = ["securitygroup_id_mgmt"]
  external_subnet_id        = [{"subnet_id" =  "subnet_id_external", "public_ip" = true }]
  external_securitygroup_id = ["securitygroup_id_external"]
  internal_subnet_id        = [{"subnet_id" =  "subnet_id_internal", "public_ip"=false }]
  internal_securitygroup_id = ["securitygropu_id_internal"]
  availabilityZones         = var.availabilityZones
}

```

#### Required Input Variables

These variables must be set in the module block when using this module.

`dnsLabel/prefix` (string)

`Description:` This value is inserted in the beginning of each Azure object. Note: requires alpha-numeric without special character

`resource_group_name` (string)

`Description:` The name of the resource group in which the resources will be created

`mgmt_subnet_ids` (List of Maps)

`Description:` Map with Subnet-id and public_ip as keys for the management subnet

`mgmt_securitygroup_ids` (List)

`Description:` securitygroup_ids for the management interface

`availabilityZones` (List)

`Description:` availabilityZones 

#### Output Variables

`mgmtPublicIP:`

`Description:` The actual ip address allocated for the resource

`mgmtPublicDNS:`

`Description:` fqdn to connect to the first vm provisioned

`mgmtPort:`

`Description:` Mgmt Port

`f5_username:`

`Description:` BIG-IP username

`bigip_password:`

`Description:` BIG-IP Password (if dynamic_password is choosen it will be random generated password or if azure_keyvault is choosen it will be key vault secret name )


