package test

import (
	"testing"

	//            "github.com/Azure/azure-sdk-for-go/services/compute/mgmt/2019-07-01/compute"

	//            "github.com/gruntwork-io/terratest/modules/azure"

	"github.com/gruntwork-io/terratest/modules/terraform"
	//	"github.com/stretchr/testify/assert"
)

func TestTerraformAzureExample(t *testing.T) {

	t.Parallel()

	terraformOptions := &terraform.Options{

		// The path to where our Terraform code is located

		TerraformDir: "../example/bigip_azure_2nic_deploy",

		Vars: map[string]interface{}{
			"location": "eastus",
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	//      vmName := terraform.Output(t, terraformOptions, "bigip_public_ip")

	//	bigipPublicDnsName := terraform.Output(t, terraformOptions, "bigip_public_dns_name")

	//	bigipUserName := terraform.Output(t, terraformOptions, "bigip_username")

	//	assert.Equal(t, "azureuser", bigipUserName)
	//	assert.Equal(t, "ecosysf5hyd2.southindia.cloudapp.azure.com", bigipPublicDnsName)

}
