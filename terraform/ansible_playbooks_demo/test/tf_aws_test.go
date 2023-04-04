package test

import (
	// "fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	// "github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestEc2(t *testing.T) {
	t.Parallel()

	folder := test_structure.CopyTerraformFolderToTemp(t, "../", "")
	aws_region := aws.GetRandomStableRegion(t, nil, []string{"us-east-1", "us-east-2", "us-west-1", "us-west-2"})
	vpc_id := aws.GetDefaultVpc(t, aws_region).Id

	terraform_options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: folder,
		Vars: map[string]interface{}{
			"vpc_id": vpc_id,
			"default_region": aws_region,
		},
	})

	defer terraform.Destroy(t, terraform_options)
	terraform.InitAndApply(t, terraform_options)

	// Outputs
	worker_node_amis := terraform.OutputList(t, terraform_options, "worker_node_amis")

	// Assertions
	// Confirm all worker nodes have a different AMI
	for i := 0; i < len(worker_node_amis); i++ {
		for j := i + 1; j < len(worker_node_amis); j++ {
			assert.False(t, worker_node_amis[i] == worker_node_amis[j])
		}
	}
}