# Module for deploying BIG-IP VE in Azure - Standalone Two NICs

## Contents

* [Introduction](#introduction)
* [Prerequisites](#prerequisites)
* [Important Configuration Notes](#important-configuration-notes)
* [Installation Example](#installation-example)
* [Configuration Example](#configuration-example)

## Introduction

This solution uses an Terraform template to launch a two NIC deployment of a cloud-focused BIG-IP VE standalone device in Microsoft Azure. Traffic flows to the BIG-IP VE which then flows to DVWA app server. This is the standard cloud design where the BIG-IP VE instance is running with a dual interface, and both management and data plane traffic is processed on each separate NIC.  

The BIG-IP VE has the [Local Traffic Manager (LTM)](https://f5.com/products/big-ip/local-traffic-manager-ltm) and [Application Security Module (ASM)](https://www.f5.com/products/security/advanced-waf) modules enabled to provide advanced traffic management functionality. This means you can also configure the BIG-IP VE to enable F5's L4/L7 security features, access control, Advance WAF and intelligent traffic management.

Terraform is beneficial as it allows composing resources a bit differently to account for dependencies into Immutable/Mutable elements. For example, mutable  includes items you would typically frequently change/mutate, such as traditional configs on the BIG-IP. Once the template is deployed, there are certain resources (network infrastructure) that are fixed while others (BIG-IP VMs and configurations) can be changed.

## Version

This template is tested and worked in the following version
Terraform v0.12.25

* provider.azurerm v2.1
* provider.local v1.4
* provider.null v2.1
* provider.template v2.1

## Prerequisites

* **Important**: When you configure the admin password for the BIG-IP VE in the template, you cannot use the character **#**.  Additionally, there are a number of other special characters that you should avoid using for F5 product user accounts.  See [K2873](https://support.f5.com/csp/article/K2873) for details.
* This template requires a service principal for backend pool service discovery. **Important**: you MUST have "OWNER" priviledge on the SP in order to assign role to the resources in your subscription. See the [Service Principal Setup section](#service-principal-authentication) for details, including required permissions.
* The HA BIG-IP VMs use Azure RBAC role for the failover instead of using Service Prinicipal.
* This deployment will be using the Terraform Azurerm provider to build out all the neccessary Azure objects. Therefore, Azure CLI is required. For installation, please follow this [Microsoft link](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)
* If this is the first time to deploy the F5 image, the subscription used in this deployment needs to be enabled to programatically deploy. For more information, please refer to [Configure Programatic Deployment](https://azure.microsoft.com/en-us/blog/working-with-marketplace-images-on-azure-resource-manager/)

## Important configuration notes

* Variables are configured in variables.tf
* Sensitive variables like Azure Subscription and Service Principal are configured in terraform.tfvars
  + Note: Passwords and secrets will be moved to Azure Key Vault in the future
* This template uses Declarative Onboarding (DO) and Application Services 3 (AS3) packages for the initial configuration. As part of the onboarding script, it will download the RPMs automatically. See the [AS3 documentation](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/) and [DO documentation](https://clouddocs.f5.com/products/extensions/f5-declarative-onboarding/latest/) for details on how to use AS3 and Declarative Onboarding on your BIG-IP VE(s). The [Telemetry Streaming](https://clouddocs.f5.com/products/extensions/f5-telemetry-streaming/latest/) extension is also downloaded but not configured to point to any remote analytics/consumers. 
* onboard.tpl is the onboarding script which is run by commandToExecute (user data). It will be copied to /var/lib/waagent/CustomData upon bootup. This script is responsible for downloading the neccessary F5 Automation Toolchain RPM files, installing them, and then executing the onboarding REST calls.
* This template uses PayGo BIGIP image for the deployment (as default). If you would like to use BYOL, then these following steps are needed:
1. In the "variables.tf", specify the BYOL image and licenses regkeys.
2. To find available images/versions, use this search example on Azure CLI:

  

``` 
          az vm image list -f BIG-IP --all
  ```

### Template parameters

| Parameter 	| Required 	| Default 	| Description 	|
|------------	|----------	|---------	| ------------	|
| dnsLabel  | Yes 	| ecosysf5hyd 	| This value is inserted in the beginning of each Azure   object. Note: requires alpha-numeric without special character 	|
| resource_group_name 	| yes 	|   	| The name of the   resource group in which the resources will be created 	|
| vnet_subnet_id 	| yes 	|   	| The subnet id of the   virtual network where the virtual machines will reside 	|
| f5_username 	| yes 	| azureuser 	| The admin username of   the F5 Bigip that will be deployed 	|
| f5_instance_type 	| yes 	| Standard_DS3_v2 	| Specifies the size of   the virtual machine 	|
| f5_image_name 	| yes 	|   	| F5 SKU (image) to you want to deploy. Note: The disk size of   the VM will be determined based on the option you select. Important: If intending to provision   multiple modules, ensure the appropriate value is selected, such as AllTwoBootLocations or AllOneBootLocation. 	|
| f5_version 	| yes 	| latest 	| It is set to default to use the latest software. 	|
| f5_product_name 	| yes 	| f5-big-ip-best 	| Azure BIG-IP VE Offer. 	|
| storage_account_type 	| yes 	| Standard_LRS 	| Defines the type of   storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS 	|
| allocation_method 	| yes 	| Dynamic 	| Defines how an IP   address is assigned. Options are Static or Dynamic 	|
| enable_accelerated_networking 	| no 	| FALSE 	| (Optional) Enable   accelerated networking on Network interface 	|
| enable_ssh_key 	| no 	| TRUE 	| (Optional) Enable ssh   key authentication in Linux virtual Machine 	|
| f5_ssh_publickey 	| no 	| ~/.ssh/id_rsa.pub 	| Path to the public   key to be used for ssh access to the VM.    Only used with non-Windows vms and can be left as-is even if using   Windows vms. If specifying a path to a certification on a Windows machine to   provision a linux vm use the / in the path versus backslash. e.g.   c:/home/id_rsa.pub 	|
| ADMIN_PASSWD 	| yes 	| Default@1234 	| Password for the Virtual Machine. 	|
| nb_instances 	| no 	| 3                             	| Specify the number of   nic interfaces 	|

## Installation Example

To run this Terraform template, perform the following steps:

  1. Clone the repo to your favorite location
  2. Modify terraform.tfvars with the required information

  

``` 
      # BIG-IP Environment
      uname     = "azureuser"
      upassword = "Default12345!"

      # Azure Environment
      sp_subscription_id = "xxxxx"
      sp_client_id       = "xxxxx"
      sp_client_secret   = "xxxxx"
      sp_tenant_id       = "xxxxx"
      location           = "West US 2"

      # Prefix for objects being created
      prefix = "mylab123"
  ```

  3. Initialize the directory

  

``` 
      terraform init
  ```

  4. Test the plan and validate errors

  

``` 
      terraform plan
  ```

  5. Finally, apply and deploy

  

``` 
      terraform apply
  ```

  6. When done with everything, don't forget to clean up!

  

``` 
      terraform destroy
  ```

## Configuration Example

The following is an example configuration diagram for this solution deployment. In this scenario, all access to the BIG-IP VE device is direct to the BIG-IP via the management interface. The IP addresses in this example may be different in your implementation.

![Configuration Example](./AzureStandalone2nic.png)

## Documentation

For more information on F5 solutions for Azure, check out the [Azure BIG-IP Lightboard Lessons](https://devcentral.f5.com/s/articles/Lightboard-Lessons-BIG-IP-Deployments-in-Azure-Cloud) on DevCentral. Also visit the F5 Networks GitHub repo for Azure ARM template examples. This particular standalone example is based on the [BIG-IP Standalone F5 ARM Cloud Template on GitHub](https://github.com/F5Networks/f5-azure-arm-templates/tree/master/supported/standalone/2nic/new-stack/payg).
