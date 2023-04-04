terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket = "tf-state-bucket-sm"
    key = "main"
    region = "us-east-2"
    dynamodb_table = "sm-dynamodb-table"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.57.1"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.19.0"
    }
  }
}

provider "aws" {
  region = var.default_region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "vpc" {
  source = "./modules/vpc"

  cidr         = "192.168.0.0/16"
  cluster_name = var.cluster_name
}

module "rds" {
  source = "./modules/rds"

  vpc_sg_id  = module.vpc.vpc_sg_id
  subnet_ids = module.vpc.private_subnets
  username   = var.username
  password   = var.password
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name                   = var.cluster_name
  cluster_version                = "1.24"
  cluster_endpoint_public_access = true
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets

  eks_managed_node_groups = {
    private = {
      name = "private"

      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 3
      desired_size = 3
    }

    public = {
      name = "public"

      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 2
    }
  }
}

module "load_balancer_controller" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-lb-controller.git"

  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  cluster_name                     = module.eks.cluster_name
}

module "elb" {
  source = "./modules/elb"

  subnets = module.vpc.public_subnets
  vpc_id  = module.vpc.vpc_id
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  db_identifier = module.rds.db_identifier
  lb_arn_suffix = module.elb.lb_arn_suffix
}