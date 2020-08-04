## Deploys F5 BIGIP Azure Cloud

This Terraform module deploys F5 BIGIP in Azure with the following characteristics:


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




## Template parameters

| Parameter 	| Type 	| Required 	| Default 	| Description 	|
|-	|-	|-	|-	|-	|
| dnsLabel/prefix 	| string 	| yes 	|  	| This value is inserted in the   beginning of each Azure object. Note: requires alpha-numeric without special   character 	|
| resource_group_name 	| string 	| yes 	|  	| The name of the resource group   in which the resources will be created 	|
| vnet_subnet_id 	| list 	| yes 	|  	| The subnet id of the virtual   network where the virtual machines will reside 	|
| vnet_subnet_security_group_ids 	| list 	| yes 	|  	| The Network Security Group id   of the virtual network 	|
| f5_username 	| string 	| yes 	| admin 	| The admin username of the F5   Bigip that will be deployed 	|
| f5_instance_type 	| string 	| yes 	| Standard_DS3_v2 	| Specifies the size of the   virtual machine 	|
| f5_image_name 	| string 	| yes 	|  	| F5 SKU (image) to you want to   deploy. Note: The disk size of the VM will be determined based on the option   you select. Important: If intending to provision multiple modules, ensure the   appropriate value is selected, such as AllTwoBootLocations or AllOneBootLocation. 	|
| f5_version 	| string 	| yes 	| latest 	| It is set to default to use the   latest software. 	|
| f5_product_name 	| string 	| yes 	| f5-big-ip-best 	| Azure BIG-IP VE Offer. 	|
| storage_account_type 	| string 	| yes 	| Standard_LRS 	| Defines the type of storage   account to be created. Valid options are Standard_LRS, Standard_ZRS,   Standard_GRS, Standard_RAGRS, Premium_LRS 	|
| allocation_method 	| string 	| yes 	| Dynamic 	| Defines how an IP address is   assigned. Options are Static or Dynamic 	|
| enable_accelerated_networking 	| bool 	| no 	| FALSE 	| (Optional) Enable accelerated   networking on Network interface 	|
| enable_ssh_key 	| bool 	| no 	| TRUE 	| (Optional) Enable ssh key   authentication in Linux virtual Machine 	|
| f5_ssh_publickey 	| string 	| no 	| ~/.ssh/id_rsa.pub 	| Path to the public key to be   used for ssh access to the VM. Only used with non-Windows vms and can be left   as-is even if using Windows vms. If specifying a path to a certification on a   Windows machine to provision a linux vm use the / in the path versus backslash.   e.g. c:/home/id_rsa.pub 	|
| ADMIN_PASSWD 	| string 	| yes 	| Default@1234 	| Password for the Virtual   Machine. 	|
| nb_nics 	| int 	| yes 	| 1 	| Specify the number of nic   interfaces 	|
| nb_public_ip 	| int 	| yes 	| 1 	| Number of public IPs to assign   corresponding to one IP per vm. Set to 0 to not assign any public IP   addresses 	|
| doPackageUrl 	| string 	| optional 	| latest 	| URL to download the BIG-IP   Declarative Onboarding module 	|
| as3PackageUrl 	| string 	| optional 	| latest 	| URL to download the BIG-IP   Application Service Extension 3 (AS3) module 	|
| tsPackageUrl 	| string 	| optional 	| latest 	| URL to download the BIG-IP   Telemetry Streaming module 	|
| fastPackageUrl 	| string 	| optional 	| latest 	| URL to download the BIG-IP FAST   module 	|
| cfePackageUrl 	| string 	| optional 	| latest 	| URL to download the BIG-IP   Cloud Failover Extension module 	|
| availabilityZones 	| list 	| yes 	| [] 	| If you want the VM placed in an   Azure Availability Zone, and the Azure region you are deploying to supports   it, specify the numbers of the existing Availability Zone you want to use 	|

# Configuration Examples

### Example Diagram for 1-nic:

![Configuration Example](./images/azure_example_1nic.png)

### Example Diagram for 2-nic:

![Configuration Example](./images/azure_example_2nic.png)

### Example Diagram for 3-nic:

![Configuration Example](./images/azure_example_3nic.png)
