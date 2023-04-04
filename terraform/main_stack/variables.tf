variable "cluster_name" {
  type    = string
  default = "SM_EKS_Cluster"
}

variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "default_region" {
  type = string
  default = "us-east-2"
}