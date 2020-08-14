## Deploys F5 BIG-IP Azure Cloud

This Terraform module deploys 1-NIC BIG-IP in Azure with the following characteristics:

BIG-IP 1 Nic as management interface associated with user provided subnet and security-group
  
A random generated password for login to BIG-IP ( Default value of az_key_vault_authentication is false )


## Steps to clone and use the provisioner locally

- clone the repository using the command `git clone`

- cd azure-deploy/examples/bigip_azure_1nic_deploy

- Then follow the stated process in Example Usage below

## Example Usage

>Modify terraform.tfvars according to the requirement by changing `location` and `AllowedIPs` variables as follows

```
location = "eastus"
AllowedIPs = ["0.0.0.0/0"]
```
Next, Run the following commands to create and destroy your configuration

- terraform init

- terraform plan

- terraform apply 

- terraform destroy

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
