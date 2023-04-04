config {
  force = false
  disabled_by_default = false
  varfile = ["terraform.tfvars"]
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  deep_check = true
  version = "0.21.2"
  source = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "terraform_module_pinned_source" {
  enabled = false
}