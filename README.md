## Deploys BIG-IP in Azure Cloud

This Terraform module deploys N-nic F5 BIG-IP in Azure cloud ,and with module count feature we can deploy multiple bigip instances.

## Prerequisites

This module is supported from Terraform 0.13 version onwards.

Below templates are tested and worked in the following version 

Terraform v0.13.0
+ provider registry.terraform.io/hashicorp/azurerm v2.28.0
+ provider registry.terraform.io/hashicorp/null v2.1.2
+ provider registry.terraform.io/hashicorp/random v2.3.0
+ provider registry.terraform.io/hashicorp/template v2.1.2

## Example Usage

We have provided some common deployment [examples](https://github.com/f5devcentral/terraform-azure-bigip-module/tree/master/examples) 

Note:
There should be one to one mapping between subnetids and securitygroupids (for example if we have 2 or more external subnetids,we have to give same number of external securitygroupids to module)


Below example snippets show how this module called.

```

Example 1-NIC Deployment Module usage

module bigip {
  count 		                  = var.instance_count
  source                      = "../../"
  prefix                      = "bigip-azure-1nic"
  resource_group_name         = "testbigip"
  mgmt_subnet_ids             = [{"subnet_id" = "subnet_id_mgmt" , "public_ip" = true}]
  mgmt_securitygroup_ids      = ["securitygroup_id_mgmt"]
  availabilityZones           =  var.availabilityZones


}


Example 2-NIC Deployment Module usage

module bigip {
  count                       = var.instance_count
  source                      = "../../"
  prefix                      = "bigip-azure-2nic"
  resource_group_name         = "testbigip"
  mgmt_subnet_ids             = [{"subnet_id" = "subnet_id_mgmt" , "public_ip" = true}]
  mgmt_securitygroup_ids      = ["securitygroup_id_mgmt"]
  external_subnet_ids         = [{"subnet_id" =  "subnet_id_external", "public_ip" = true }]
  external_securitygroup_ids  = ["securitygroup_id_external"]
  availabilityZones           =  var.availabilityZones
}


Example 3-NIC Deployment  Module usage 

module bigip {
  count                       = var.instance_count 
  source                      = "../../"
  prefix                      = "bigip-azure-3nic"
  resource_group_name         = "testbigip"
  mgmt_subnet_ids             = [{"subnet_id" = "subnet_id_mgmt" , "public_ip" = true}]
  mgmt_securitygroup_ids      = ["securitygroup_id_mgmt"]
  external_subnet_ids         = [{"subnet_id" =  "subnet_id_external", "public_ip" = true }]
  external_securitygroup_ids  = ["securitygroup_id_external"]
  internal_subnet_ids         = [{"subnet_id" =  "subnet_id_internal", "public_ip"=false }]
  internal_securitygroup_ids  = ["securitygropu_id_internal"]
  availabilityZones           =  var.availabilityZones
}

Example 4-NIC Deployment  Module usage(with 2 external public interfaces,one management and internal interface.There should be one to one mapping between subnetids and securitygroupids)

module bigip {
  count                       = var.instance_count
  source                      = "../../"
  prefix                      = "bigip-azure-4nic"
  resource_group_name         = "testbigip"
  mgmt_subnet_ids             = [{"subnet_id" = "subnet_id_mgmt" , "public_ip" = true}]
  mgmt_securitygroup_ids      = ["securitygroup_id_mgmt"]
  external_subnet_ids         = [{"subnet_id" =  "subnet_id_external", "public_ip" = true },{"subnet_id" =  "subnet_id_external2", "public_ip" = true }]
  external_securitygroup_ids  = ["securitygroup_id_external","securitygroup_id_external"]
  internal_subnet_ids         = [{"subnet_id" =  "subnet_id_internal", "public_ip"=false }]
  internal_securitygroup_ids  = ["securitygropu_id_internal"]
  availabilityZones           =  var.availabilityZones
}

.............

Similarly we can have N-nic deployments based on user provided subnet_ids and securitygroup_ids.
With module count, user can deploy multiple bigip instances in the azure cloud (with the default value of count being one )


```


#### Required Input Variables

These variables must be set in the module block when using this module.

| Name | Description | Type | 
|------|-------------|------|
| prefix | This value is inserted in the beginning of each Azure object. Note: requires alpha-numeric without special character | `string` |
| resource\_group\_name | The name of the resource group in which the resources will be created | `string` |
| mgmt\_subnet\_ids | Map with Subnet-id and public_ip as keys for the management subnet | `List of Maps` |
| mgmt\_securitygroup\_ids | securitygroup\_ids for the management interface | `List` |
| availabilityZones | availabilityZones | `List` |
| instance\_count | Number of Bigip instances to spin up | `number` |

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
NOTE: A local json file will get generated which contains the DO declaration (for 1,2,3 nics as provided in the examples )
```


## Support Information

This repository is community-supported. Follow instructions below on how to raise issues.

### Filing Issues and Getting Help

If you come across a bug or other issue, use [GitHub Issues](https://github.com/f5devcentral/terraform-azure-bigip-module/issues) to submit an issue for our team.  You can also see the current known issues on that page, which are tagged with a purple Known Issue label.

## Copyright

Copyright 2014-2019 F5 Networks Inc.

### F5 Networks Contributor License Agreement

Before you start contributing to any project sponsored by F5 Networks, Inc. (F5) on GitHub, you will need to sign a Contributor License Agreement (CLA).

If you are signing as an individual, we recommend that you talk to your employer (if applicable) before signing the CLA since some employment agreements may have restrictions on your contributions to other projects. Otherwise by submitting a CLA you represent that you are legally entitled to grant the licenses recited therein.

If your employer has rights to intellectual property that you create, such as your contributions, you represent that you have received permission to make contributions on behalf of that employer, that your employer has waived such rights for your contributions, or that your employer has executed a separate CLA with F5.

If you are signing on behalf of a company, you represent that you are legally entitled to grant the license recited therein. You represent further that each employee of the entity that submits contributions is authorized to submit such contributions on behalf of the entity pursuant to the CLA.
