variable "create" {
  type    = bool
  default = true
}

variable "label_version" {
  type    = string
  default = "latest"
}

variable "repository" {
  type = string
}

variable "namespace" {
  type    = string
  default = "aline"
}