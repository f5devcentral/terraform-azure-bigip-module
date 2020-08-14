## Deploys BIG-IP in Azure Cloud

This Terraform module deploys N-nic F5 BIG-IP in Azure cloud


## Example Usage

We have provided some common deployment examples below.(1-nic,2-nic,3-nic )

```
Example 1-NIC Deployment

module bigip {
 source                      = "../"
  dnsLabel                    = "bigip-azure-1nic"
  resource_group_name         = "testbigip"
  mgmt_subnet_id              = [{"subnet_id" = "subnet_id_mgmt" , "public_ip" = true}]
  mgmt_securitygroup_id       = ["securitygroup_id_mgmt"]
  availabilityZones           =  var.availabilityZones


}


Example 2-NIC Deployment

module bigip {
  source                      = "../"
  dnsLabel                    = "bigip-azure-2nic"
  resource_group_name         = "testbigip"
  mgmt_subnet_id              = [{"subnet_id" = "subnet_id_mgmt" , "public_ip" = true}]
  mgmt_securitygroup_id       = ["securitygroup_id_mgmt"]
  external_subnet_id          = [{"subnet_id" =  "subnet_id_external", "public_ip" = true }]
  external_securitygroup_id   = ["securitygroup_id_external"]
  availabilityZones           =  var.availabilityZones
}





Example 3-NIC Deployment


module bigip {
  source                      = "../"
  dnsLabel                    = "bigip-azure-3nic"
  resource_group_name         = "testbigip"
  mgmt_subnet_id              = [{"subnet_id" = "subnet_id_mgmt" , "public_ip" = true}]
  mgmt_securitygroup_id       = ["securitygroup_id_mgmt"]
  external_subnet_id          = [{"subnet_id" =  "subnet_id_external", "public_ip" = true }]
  external_securitygroup_id   = ["securitygroup_id_external"]
  internal_subnet_id          = [{"subnet_id" =  "subnet_id_internal", "public_ip"=false }]
  internal_securitygroup_id   = ["securitygropu_id_internal"]
  availabilityZones           =  var.availabilityZones
}


```

#### Required Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| dnsLabel/prefix | This value is inserted in the beginning of each Azure object. Note: requires alpha-numeric without special character | `string` | n/a | yes |
| resource\_group\_name | The name of the resource group in which the resources will be created | `string` | n/a | yes |
| mgmt\_subnet\_ids | Map with Subnet-id and public_ip as keys for the management subnet | `List of Maps` | n/a | yes |
| mgmt\_securitygroup\_ids | securitygroup\_ids for the management interface | `List` | n/a | yes |
| availabilityZones | availabilityZones | `List` | n/a | yes |
| f5\_username | The admin username of the F5   BIG-IP that will be deployed | `string` | bigipuser | no |
| f5\_instance\_type | Specifies the size of the virtual machine | `string` | Standard\_DS3\_v2| no |
| f5\_image\_name | 5 SKU (image) to you want to deploy. Note: The disk size of the VM will be determined based on the option you select. Important: If intending to provision multiple modules, ensure the appropriate value is selected, such as AllTwoBootLocations or AllOneBootLocation | `string` | | no |
| f5\_version | It is set to default to use the latest software | `string` | latest | no |
| f5\_product\_name | Azure BIG-IP VE Offer | `string` | f5-big-ip-best | no |
| storage\_account\_type | Defines the type of storage account to be created. Valid options are Standard\_LRS, Standard\_ZRS, Standard\_GRS, Standard\_RAGRS, Premium\_LRS | `string` | Standard\_LRS | no |
| allocation\_method | Defines how an IP address is assigned. Options are Static or Dynamic | `string` | Dynamic | no |
| enable\_accelerated\_networking | Enable accelerated networking on Network interface | `bool` | FALSE | no |
| enable\_ssh\_key | Enable ssh key authentication in Linux virtual Machine | `bool` | TRUE | no |
| f5\_ssh\_publickey | Path to the public key to be used for ssh access to the VM. Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash. e.g. c:/home/id\_rsa.pub | `string` | ~/.ssh/id\_rsa.pub | no |
| doPackageUrl | URL to download the BIG-IP Declarative Onboarding module | `string` | latest | no |
| as3PackageUrl | URL to download the BIG-IP Application Service Extension 3 (AS3) module | `string` | latest | no |
| tsPackageUrl | URL to download the BIG-IP Telemetry Streaming module | `string` | latest | no |
| fastPackageUrl | URL to download the BIG-IP FAST module | `string` | latest | no |



`f5_username` (string)

`Description:` The admin username of the F5   BIG-IP that will be deployed

`Default:` bigipuser

`f5_instance_type` (string)

`Description:` Specifies the size of the   virtual machine

`Default:` Standard_DS3_v2

`f5_image_name` (string)

`Description:` 5 SKU (image) to you want to   deploy. Note: The disk size of the VM will be determined based on the option   you select. Important: If intending to provision multiple modules, ensure the   appropriate value is selected, such as AllTwoBootLocations or AllOneBootLocation.

`Default:`

`f5_version` (string)

`Description:` It is set to default to use the   latest software.

`Default:` latest

`f5_product_name` (string)

`Description:` Azure BIG-IP VE Offer.

`Default:` f5-big-ip-best

`storage_account_type` (string)

`Description:` Defines the type of storage   account to be created. Valid options are Standard_LRS, Standard_ZRS,   Standard_GRS, Standard_RAGRS, Premium_LRS

`Default:` Standard_LRS

`allocation_method:` (string)

`Description:` Defines how an IP address is   assigned. Options are Static or Dynamic

`Default:` Dynamic

`enable_accelerated_networking` (bool)

`Description:` Enable accelerated   networking on Network interface


`Default:` FALSE

`enable_ssh_key` (bool)

`Description:` Enable ssh key   authentication in Linux virtual Machine

`Default:` TRUE

`f5_ssh_publickey` (string)

`Description:` Path to the public key to be   used for ssh access to the VM. Only used with non-Windows vms and can be left   as-is even if using Windows vms. If specifying a path to a certification on a   Windows machine to provision a linux vm use the / in the path versus backslash.   e.g. c:/home/id_rsa.pub

`Default:` ~/.ssh/id_rsa.pub

`doPackageUrl` (string)

`Description:` URL to download the BIG-IP   Declarative Onboarding module

`Default:` latest

`as3PackageUrl` (string)

`Description:` URL to download the BIG-IP   Application Service Extension 3 (AS3) module

`Default:` latest

`tsPackageUrl` (string)

`Description:` URL to download the BIG-IP  Telemetry Streaming module

`Default:` latest

`fastPackageUrl` (string)

`Description:` URL to download the BIG-IP FAST   module

`Default:` latest

`cfePackageUrl` (string)

`Description:` URL to download the BIG-IP   Cloud Failover Extension module

`Default:` latest

`libs_dir` (string)

`Description:` Directory on the BIG-IP to download the A&O Toolchain into

`Default:` /config/cloud/azure/node_modules

`onboard_log` (string)

`Description:` Directory on the BIG-IP to store the cloud-init logs

`Default:` /var/log/startup-script.log

`azure_secret_rg:` (string)

`Description:` The name of the resource group in which the Azure Key Vault exists

`Default:` ""

`az_key_vault_authentication:` (string)

`Description:` Whether to use key vault to pass authentication

`Default:` false

`azure_keyvault_name:` (string)

`Description:` The name of the Azure Key Vault to use

`Default:` ""

`azure_keyvault_secret_name:` (string)

`Description:` The name of the Azure Key Vault secret containing the password

`Default:` ""

#### Output Variables
| Name | Description |
|------|-------------|
| mgmtPublicIP | The actual ip address allocated for the resource |
| mgmtPublicDNS | fqdn to connect to the first vm provisioned |
| mgmtPort | Mgmt Port |
| f5\_username | BIG-IP username |
| bigip\_password | BIG-IP Password (if dynamic_password is choosen it will be random generated password or if azure_keyvault is choosen it will be key vault secret name ) |


```
NOTE: A local json file will get generated which contains the DO declaration
```
