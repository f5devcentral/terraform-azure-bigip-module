## Deploys BIG-IP in Azure Cloud

This Terraform module deploys N-nic F5 BIG-IP in Azure cloud,and with module count feature we can also deploy multiple instances of BIG-IP.

## Prerequisites

This module is supported from Terraform 0.13 version onwards.

Below templates are tested and worked in the following version 

Terraform v0.13.0
+ provider registry.terraform.io/hashicorp/azurerm v2.28.0
+ provider registry.terraform.io/hashicorp/null v2.1.2
+ provider registry.terraform.io/hashicorp/random v2.3.0
+ provider registry.terraform.io/hashicorp/template v2.1.2

## Releases and Versioning

This module is supported in the following bigip and terraform version

| BIGIP version | Terraform 0.13 | 
|---------------|----------------|
| BIG-IP 15.x  | X |
| BIG-IP 14.x  | X |
| BIG-IP 13.x  | X |

## Password Management

By default bigip module will have random password setting to give dynamic password generation

```
variable az_key_vault_authentication {
  description = "Whether to use key vault to pass authentication"
  type        = bool
  default     = false
}

Outputs:
bigip_password = [
  "xxxxxxxxxxxxxxxxxx",
]
```

```
To use Azure secret key vault, we have to enable the variable "az_key_vault_authentication" to true and supply the below respective variables with key_valut name,secret along with resource group name where azure key vault is defined"

variable az_key_vault_authentication {
  description = "Whether to use key vault to pass authentication"
  type        = bool
  default     = false
}

variable azure_secret_rg {
  description = "The name of the resource group in which the Azure Key Vault exists"
  type        = string
  default     = ""
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

Outputs:
bigip_password = [
  "xxxxxxxxxxxxxxxxxx",
]

```

## Example Usage

We have provided some common deployment [examples](https://github.com/f5devcentral/terraform-azure-bigip-module/tree/master/examples) 

#### Note
There should be one to one mapping between subnet_ids and securitygroupids (for example if we have 2 or more external subnet_ids,we have to give same number of external securitygroupids to module)

Users can have dynamic or static private ip allocation.If primary/secondary private ip value is null, it will be dynamic or else static private ip allocation.

```
With Static private ip allocation we can assign primary and secondary private ips for external interfaces, whereas primary private ip for management
and internal interfaces.
```

If it is static private ip allocation we can't use module count as same private ips will be tried to allocate for multiple 
bigip instances based on module count.

With Dynamic private ip allocation,we have to pass null value to primary/secondary private ip declaration and module count will be supported.

Below example snippets show how this module is called. ( Dynamic private ip allocation )

```

Example 1-NIC Deployment Module usage

module bigip {
  count 		      = var.instance_count
  source                      = "../../"
  prefix                      = "bigip-azure-1nic"
  resource_group_name         = "testbigip"
  mgmt_subnet_ids             = [{"subnet_id" = "subnet_id_mgmt" , "public_ip" = true,"private_ip_primary" =  ""}]
  mgmt_securitygroup_ids      = ["securitygroup_id_mgmt"]
  availabilityZones           =  var.availabilityZones


}


Example 2-NIC Deployment Module usage

module bigip {
  count                       = var.instance_count
  source                      = "../../"
  prefix                      = "bigip-azure-2nic"
  resource_group_name         = "testbigip"
  mgmt_subnet_ids             = [{"subnet_id" = "subnet_id_mgmt" , "public_ip" = true, "private_ip_primary" =  ""}]
  mgmt_securitygroup_ids      = ["securitygroup_id_mgmt"]
  external_subnet_ids         = [{"subnet_id" =  "subnet_id_external", "public_ip" = true,"private_ip_primary" = "", "private_ip_secondary" = "" }]
  external_securitygroup_ids  = ["securitygroup_id_external"]
  availabilityZones           =  var.availabilityZones
}


Example 3-NIC Deployment  Module usage 

module bigip {
  count                       = var.instance_count 
  source                      = "../../"
  prefix                      = "bigip-azure-3nic"
  resource_group_name         = "testbigip"
  mgmt_subnet_ids             = [{"subnet_id" = "subnet_id_mgmt" , "public_ip" = true, "private_ip_primary" =  ""}]
  mgmt_securitygroup_ids      = ["securitygroup_id_mgmt"]
  external_subnet_ids         = [{"subnet_id" =  "subnet_id_external", "public_ip" = true, "private_ip_primary" = "", "private_ip_secondary" = "" }]
  external_securitygroup_ids  = ["securitygroup_id_external"]
  internal_subnet_ids         = [{"subnet_id" =  "subnet_id_internal", "public_ip"=false, "private_ip_primary" = "" }]
  internal_securitygroup_ids  = ["securitygropu_id_internal"]
  availabilityZones           =  var.availabilityZones
}

Example 4-NIC Deployment  Module usage(with 2 external public interfaces,one management and internal interface.There should be one to one mapping between subnet_ids and securitygroupids)

module bigip {
  count                       = var.instance_count
  source                      = "../../"
  prefix                      = "bigip-azure-4nic"
  resource_group_name         = "testbigip"
  mgmt_subnet_ids             = [{"subnet_id" = "subnet_id_mgmt" , "public_ip" = true, "private_ip_primary" =  ""}]
  mgmt_securitygroup_ids      = ["securitygroup_id_mgmt"]
  external_subnet_ids         = [{"subnet_id" = "subnet_id_external", public_ip" = true, "private_ip_primary" = "", "private_ip_secondary" = "" },{"subnet_id" = subnet_id_external2", public_ip" = true, "private_ip_primary" = "", "private_ip_secondary" = "" }]
  external_securitygroup_ids  = ["securitygroup_id_external","securitygroup_id_external"]
  internal_subnet_ids         = [{"subnet_id" =  "subnet_id_internal", "public_ip"=false, "private_ip_primary" = "" }]
  internal_securitygroup_ids  = ["securitygropu_id_internal"]
  availabilityZones           =  var.availabilityZones
}

.............

Similarly we can have N-nic deployments based on user provided subnet_ids and securitygroup_ids.
With module count, user can deploy multiple bigip instances in the azure cloud (with the default value of count being one )

```
#### Below is the example snippet for private ip allocation

```
Example 3-NIC Deployment with static private ip allocation

module bigip {
  count                      = var.instance_count
  source                     = "../../"
  prefix                     = format("%s-3nic", var.prefix)
  resource_group_name        = azurerm_resource_group.rg.name
  mgmt_subnet_ids            = [{ "subnet_id" = data.azurerm_subnet.mgmt.id, "public_ip" = true, "private_ip_primary" =  "10.2.1.5"}]
  mgmt_securitygroup_ids     = [module.mgmt-network-security-group.network_security_group_id]
  external_subnet_ids        = [{ "subnet_id" = data.azurerm_subnet.external-public.id, "public_ip" = true, 
                                "private_ip_primary" = "10.2.2.40","private_ip_secondary" = "10.2.2.50" }]
  external_securitygroup_ids = [module.external-network-security-group-public.network_security_group_id]
  internal_subnet_ids        = [{ "subnet_id" = data.azurerm_subnet.internal.id, "public_ip" = false, "private_ip_primary" = "10.2.3.40"}]
  internal_securitygroup_ids = [module.internal-network-security-group.network_security_group_id]
  availabilityZones          = var.availabilityZones
}

```


### BIG-IP Automation Toolchain InSpec Profile for testing readiness of Automation Tool Chain components 

After the module deployment, we can use inspec tool for verifying the Bigip connectivity along with ATC components

This InSpec profile evaluates the following:

* Basic connectivity to a BIG-IP management endpoint ('bigip-connectivity')
* Availability of the Declarative Onboarding (DO) service ('bigip-declarative-onboarding')
* Version reported by the Declarative Onboarding (DO) service ('bigip-declarative-onboarding-version')
* Availability of the Application Services (AS3) service ('bigip-application-services')
* Version reported by the Application Services (AS3) service ('bigip-application-services-version')
* Availability of the Telemetry Streaming (TS) service ('bigip-telemetry-streaming')
* Version reported by the Telemetry Streaming (TS) service ('bigip-telemetry-streaming-version')
* Availability of the Cloud Failover Extension( CFE ) service ('bigip-cloud-failover-extension')
* Version reported by the Cloud Failover Extension( CFE ) service('bigip-cloud-failover-extension-version')

#### run inspec tests

we can either run inspec exec command or execute runtests.sh in any one of example nic folder which will run below inspec command

inspec exec inspec/bigip-ready  --input bigip_address=$BIGIP_MGMT_IP bigip_port=$BIGIP_MGMT_PORT user=$BIGIP_USER password=$BIGIP_PASSWORD do_version=$DO_VERSION as3_version=$AS3_VERSION ts_version=$TS_VERSION fast_version=$FAST_VERSION cfe_version=$CFE_VERSION

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
| external\_subnet\_ids | List of maps of subnetids of the virtual network where the virtual machines will reside | `List of Maps` | [{ "subnet_id" = null, "public_ip" = null,"private_ip_primary" = "", "private_ip_secondary" = "" }] |
| internal\_subnet\_ids | List of maps of subnetids of the virtual network where the virtual machines will reside | `List of Maps` | [{ "subnet_id" = null, "public_ip" = null,"private_ip_primary" = "" }] |
| external\_securitygroup\_ids | List of network Security Groupids for external network | `List` | [] |
| internal\_securitygroup\_ids | List of network Security Groupids for internal network | `List` | [] |

#### Output Variables
| Name | Description |
|------|-------------|
| mgmtPublicIP | The actual ip address allocated for the resource |
| mgmtPublicDNS | fqdn to connect to the first vm provisioned |
| mgmtPort | Mgmt Port |
| f5\_username | BIG-IP username |
| bigip\_password | BIG-IP Password (if dynamic_password is choosen it will be random generated password or if azure_keyvault is choosen it will be key vault secret name ) |
| public_addresses | List of BIG-IP public addresses |
| private_addresses | List of BIG-IP private addresses |

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
