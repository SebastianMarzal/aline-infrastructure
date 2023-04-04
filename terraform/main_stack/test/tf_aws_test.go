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

func TestVpc(t *testing.T) {
	vpc_folder := test_structure.CopyTerraformFolderToTemp(t, "../", "modules/vpc")
	aws_region := aws.GetRandomStableRegion(t, []string{"us-east-2"}, []string{"us-west-1", "us-west-2"})
	cluster_name := "test-aline"

	terraform_options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: vpc_folder,
		Vars: map[string]interface{}{
			"cluster_name": cluster_name,
			"cidr": "10.0.0.0/16",
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": aws_region,
		},
	})

	defer terraform.Destroy(t, terraform_options)
	terraform.InitAndApply(t, terraform_options)

	// Outputs
	vpc_id := terraform.Output(t, terraform_options, "vpc_id")
	public_subnets := terraform.OutputList(t, terraform_options, "public_subnets")
	private_subnets := terraform.OutputList(t, terraform_options, "private_subnets")
	// vpc_sg_id := terraform.Output(t, terraform_options, "vpc_sg_id")

	// Assertions
	// Subnets in VPC == 1 Public Subnet in each region, 1 Private Subnet in each region
	assert.Equal(t, len(aws.GetSubnetsForVpc(t, vpc_id, aws_region)), 2 * len(aws.GetAvailabilityZones(t, aws_region)))
	// Output of public_subnets must be all public subnets and Kubernetes tags must be present
	for _, subnet := range public_subnets {
		assert.True(t, aws.IsPublicSubnet(t, subnet, aws_region))
		tags := aws.GetTagsForSubnet(t, subnet, aws_region)
		assert.Equal(t, "shared", tags["kubernetes.io/cluster/" + cluster_name])
		assert.Equal(t, "1", tags["kubernetes.io/role/elb"])
	}
	// Output of private_subnets must be all private subnets and Kubernetes tags must be present
	for _, subnet := range private_subnets {
		assert.False(t, aws.IsPublicSubnet(t, subnet, aws_region))
		tags := aws.GetTagsForSubnet(t, subnet, aws_region)
		assert.Equal(t, "shared", tags["kubernetes.io/cluster/" + cluster_name])
		assert.Equal(t, "1", tags["kubernetes.io/role/internal-elb"])
	}
}