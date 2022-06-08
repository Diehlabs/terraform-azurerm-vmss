package test

import (
	"context"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	auth "github.com/hashicorp/vault/api/auth/approle"
	"github.com/stretchr/testify/assert"
	"github.com/terratest_helper"
)

var uniqueId = getUniqueId()

type RunSettings struct {
	t               *testing.T
	roleId          string
	secretId        *auth.SecretID
	vaultSecretPath string
	tfCliPath       string
	workingDir      string

	vmNodeCount              int
	networkResourceGroupName string
	vnetName                 string
	subnetName               string
	product                  string
	costCenter               string
	environment              string
	region                   string
	owner                    string
	technicalContact         string

	azdoRepoName string
	azdoBuildId  string

	azClientId       string
	azClientSecret   string
	azTenantId       string
	azSubscriptionId string
}

func (r *RunSettings) setDefaults() {
	r.vaultSecretPath = "cloudauto/data/terraform/nonprod/azure/spn_infra"
	r.azdoBuildId = uniqueId

	if r.t == nil {
		panic("No Terratest module provided")
	}

	r.workingDir = "../examples/build"
	if tfdir := os.Getenv("TERRATEST_WORKING_DIR"); tfdir != "" {
		r.workingDir = tfdir
	}

	r.tfCliPath = "/usr/local/bin/terraform"
	if tfcp := os.Getenv("AGENT_TEMPDIRECTORY"); tfcp != "" {
		r.tfCliPath = tfcp + "/terraform"
	}

	r.azdoRepoName = "local-vmss-test-rg"
	if arn := os.Getenv("BUILD_REPOSITORY_NAME"); arn != "" {
		r.azdoRepoName = arn
	}

	if role_id := os.Getenv("VAULT_APPROLE_ID"); role_id != "" {
		r.roleId = role_id
	}

	if wrapped_token := os.Getenv("VAULT_WRAPPED_TOKEN"); wrapped_token != "" {
		r.secretId = &auth.SecretID{FromEnv: "VAULT_WRAPPED_TOKEN"}
	}

	// get secrets - GetSecretWithAppRole injects variables in to the environment see azure credentials
	spn, err := terratest_helper.GetSecretWithAppRole(r.roleId, r.secretId, r.vaultSecretPath)
	if err != nil {
		fmt.Print(err)
		panic(err)
	}

	logger.Logf(r.t, "Found Service Principal to use %s", spn)

	if azClientId := os.Getenv("AZURE_CLIENT_ID"); azClientId != "" {
		r.azClientId = azClientId
	}

	if azClientSecret := os.Getenv("AZURE_CLIENT_SECRET"); azClientSecret != "" {
		r.azClientSecret = azClientSecret
	}

	if azTenantId := os.Getenv("AZURE_TENANT_ID"); azTenantId != "" {
		r.azTenantId = azTenantId
	}

	if azSubscriptionId := os.Getenv("AZURE_SUBSCRIPTION_ID"); azSubscriptionId != "" {
		r.azSubscriptionId = azSubscriptionId
	}
}
func TestTerraformModule(t *testing.T) {

	r := RunSettings{t: t}
	r.setDefaults()

	// specific VMSS module variables
	r.vmNodeCount = 2
	r.networkResourceGroupName = "Networking-DevTest-RG"
	r.vnetName = "hub-devtest-vnet"
	r.subnetName = "westus-test-subnet-terratest"
	r.product = "cloudauto-test"
	r.costCenter = "001245"
	r.environment = "devtest"
	r.region = "westus"
	r.owner = "Diehlabs"
	r.technicalContact = "devops@diehlabs.com"

	t.Parallel()

	// to set terraform options
	// to skip execution "export SKIP_set_terraformOptions=true" in terminal
	test_structure.RunTestStage(t, "setTerraformOptions", r.setTerraformOptions)

	// defer terraform.Destroy(t, terraformOptions)
	// to skip execution "export SKIP_test_cleanupModule=true" in terminal
	defer test_structure.RunTestStage(t, "cleanupModule", r.cleanupModule)

	// initial deployment
	// to skip execution "export SKIP_deployModule=true" in terminal
	test_structure.RunTestStage(t, "deploy_module", r.deploy)

	// functional tests
	// to skip execution "export SKIP_test_resources=true" in terminal
	test_structure.RunTestStage(t, "test_resources", r.testResources)

	// redeploy to test idempotency
	// to skip execution "export SKIP_test_idempotency=true" in terminal
	// test_structure.RunTestStage(t, "test_idempotency", r.redeploy)
}

func (r *RunSettings) testResources() {
	terraformOptions := test_structure.LoadTerraformOptions(r.t, r.workingDir)

	actualVMScaleSetName := terraform.Output(r.t, terraformOptions, "linux_virtual_machine_scale_set_name")

	expectedResourceGroupName := fmt.Sprintf("%s-%s-%s-rg-%s", r.product, r.region, r.environment, uniqueId)
	actualResourceGroupName := terraform.Output(r.t, terraformOptions, "linux_virtual_machine_scale_set_resource_group_name")
	assert.Equal(r.t, expectedResourceGroupName, actualResourceGroupName)

	ctx, cancel := context.WithTimeout(context.Background(), 6000*time.Second)
	defer cancel()

	actualVmSSId := terraform.Output(r.t, terraformOptions, "linux_virtual_machine_scale_set_id")
	vmss, err := GetVMSS(ctx, r.azSubscriptionId, actualResourceGroupName, actualVMScaleSetName)

	if err != nil {
		fmt.Print(err)
		panic(err)
	}

	assert.Equal(r.t, *vmss.ID, actualVmSSId)
	assert.Equal(r.t, *vmss.Name, actualVMScaleSetName)

	// TODO: testing more VM scale set properties.
	// generatedIdentityType := terraform.Output(r.t, terraformOptions, "linux_virtual_machine_scale_set_identity_type")
	// assert.Equal(r.t, *vmss.Identity.Type, generatedIdentityType)
	// 	generatedIdentityId := terraform.Output(r.t, terraformOptions, "linux_virtual_machine_scale_set_identity_id")
	// 	assert.Equal(r.t, *&vmss.Identity.UserAssignedIdentities["*"].Id, generatedIdentityId)
}

func (r *RunSettings) setTerraformOptions() {
	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(r.t, &terraform.Options{
		TerraformDir:    r.workingDir,
		TerraformBinary: r.tfCliPath,
		Vars: map[string]interface{}{
			"unique_id":                   uniqueId,
			"vm_node_count":               r.vmNodeCount,
			"network_resource_group_name": r.networkResourceGroupName,
			"vnet_name":                   r.vnetName,
			"subnet_name":                 r.subnetName,
			"tags": map[string]string{
				"product":           r.product,
				"cost_center":       r.costCenter,
				"environment":       r.environment,
				"region":            r.region,
				"owner":             r.owner,
				"technical_contact": r.technicalContact,
			},
		},
	})

	test_structure.SaveTerraformOptions(r.t, r.workingDir, terraformOptions)
}

func (r *RunSettings) cleanupModule() {
	terraformOptions := test_structure.LoadTerraformOptions(r.t, r.workingDir)
	terraform.Destroy(r.t, terraformOptions)
}

func (r *RunSettings) deploy() {
	terraformOptions := test_structure.LoadTerraformOptions(r.t, r.workingDir)
	terraform.InitAndApply(r.t, terraformOptions)
	// terraform.InitAndPlan(r.t, terraformOptions)
}

func (r *RunSettings) redeploy() {
	terraformOptions := test_structure.LoadTerraformOptions(r.t, r.workingDir)
	terraform.ApplyAndIdempotent(r.t, terraformOptions)
}

func getUniqueId() string {
	// if env var BUILD_BUILDID is not empty return the value
	localId := os.Getenv("BUILD_BUILDID")

	if localId != "" {
		return localId
	} else {
		return random.UniqueId()
	}
}
