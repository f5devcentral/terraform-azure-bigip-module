## Deploys BIG-IP in Azure Cloud

This Terraform module deploys N-nic F5 BIG-IP in Azure cloud


## Example Usage

We have provided some common deployment examples below.(1-nic,2-nic,3-nic )

```

Example 1-NIC Deployment Module usage

module bigip {
 source                      = "../"
  dnsLabel                    = "bigip-azure-1nic"
  resource_group_name         = "testbigip"
  mgmt_subnet_id              = [{"subnet_id" = "subnet_id_mgmt" , "public_ip" = true}]
  mgmt_securitygroup_id       = ["securitygroup_id_mgmt"]
  availabilityZones           =  var.availabilityZones


}


Example 2-NIC Deployment Module usage

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





Example 3-NIC Deployment  Module usage

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

These variables must be set in the module block when using this module.

| Name | Description | Type | 
|------|-------------|------|
| dnsLabel/prefix | This value is inserted in the beginning of each Azure object. Note: requires alpha-numeric without special character | `string` |
| resource\_group\_name | The name of the resource group in which the resources will be created | `string` |
| mgmt\_subnet\_ids | Map with Subnet-id and public_ip as keys for the management subnet | `List of Maps` |
| mgmt\_securitygroup\_ids | securitygroup\_ids for the management interface | `List` |
| availabilityZones | availabilityZones | `List` |

#### Optional Input Variables

These variables have default values and don't have to be set to use this module. You may set these variables to override their default values.

| Name | Description | Type | Default |
|------|-------------|------|---------|
| f5\_username | The admin username of the F5   BIG-IP that will be deployed | `string` | bigipuser |
| f5\_instance\_type | Specifies the size of the virtual machine | `string` | Standard\_DS3\_v2|
| f5\_image\_name | 5 SKU (image) to you want to deploy. Note: The disk size of the VM will be determined based on the option you select. Important: If intending to provision multiple modules, ensure the appropriate value is selected, such as AllTwoBootLocations or AllOneBootLocation | `string` | f5-bigip-virtual-edition-200m-best-hourly |
| f5\_version | It is set to default to use the latest software | `string` | latest |
| f5\_product\_name | Azure BIG-IP VE Offer | `string` | f5-big-ip-best | 
| storage\_account\_type | Defines the type of storage account to be created. Valid options are Standard\_LRS, Standard\_ZRS, Standard\_GRS, Standard\_RAGRS, Premium\_LRS | `string` | Standard\_LRS |
| allocation\_method | Defines how an IP address is assigned. Options are Static or Dynamic | `string` | Dynamic | 
| enable\_accelerated\_networking | Enable accelerated networking on Network interface | `bool` | FALSE | 
| enable\_ssh\_key | Enable ssh key authentication in Linux virtual Machine | `bool` | TRUE | 
| f5\_ssh\_publickey | Path to the public key to be used for ssh access to the VM. Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash. e.g. c:/home/id\_rsa.pub | `string` | ~/.ssh/id\_rsa.pub | 
| doPackageUrl | URL to download the BIG-IP Declarative Onboarding module | `string` | latest | 
| as3PackageUrl | URL to download the BIG-IP Application Service Extension 3 (AS3) module | `string` | latest | 
| tsPackageUrl | URL to download the BIG-IP Telemetry Streaming module | `string` | latest | 
| fastPackageUrl | URL to download the BIG-IP FAST module | `string` | latest | 
| cfePackageUrl | URL to download the BIG-IP Cloud Failover Extension module | `string` | latest |
| libs\_dir | Directory on the BIG-IP to download the A&O Toolchain into | `string` | /config/cloud/azure/node_modules |
| onboard\_log | Directory on the BIG-IP to store the cloud-init logs | `string` | /var/log/startup-script.log |
| azure\_secret\_rg | The name of the resource group in which the Azure Key Vault exists | `string` | "" |
| az\_key\_vault\_authentication | Whether to use key vault to pass authentication | `string` | false |
| azure\_keyvault\_name | The name of the Azure Key Vault to use | `string` | "" |
| azure\_keyvault\_secret\_name | The name of the Azure Key Vault secret containing the password | `string` | "" |
| external\_subnet\_id | he subnet id of the virtual network where the virtual machines will reside | `List of Maps` | [{ "subnet_id" = null, "public_ip" = null }] |
| internal\_subnet\_id | The subnet id of the virtual network where the virtual machines will reside | `List of Maps` | [{ "subnet_id" = null, "public_ip" = null }] |
| external\_securitygroup\_id | The Network Security Group ids for external network | `List` | [] |
| internal\_securitygroup\_id | The Network Security Group ids for internal network | `List` | [] |

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
