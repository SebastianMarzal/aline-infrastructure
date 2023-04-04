variable "vpc_sg_id" {
  type = string
}

variable "subnet_ids" {
  type = list(any)
}

variable "password" {
  type = string
}

variable "username" {
  type = string
}

variable "db_name" {
  type = string
  default = "alinedb"
}

variable "db_engine" {
  type = string
  default = "mysql"
}

variable "db_engine_version" {
  type = string
  default = "8.0.28"
}

variable "db_instance" {
  type = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type = number
  default = 50
}