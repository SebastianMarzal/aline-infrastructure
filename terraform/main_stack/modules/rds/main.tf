resource "aws_db_subnet_group" "this" {
  name       = "sm_subnet_group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "this" {
  allocated_storage   = var.db_allocated_storage
  db_name             = var.db_name
  engine              = var.db_engine
  engine_version      = var.db_engine_version
  instance_class      = var.db_instance
  identifier          = var.db_name
  username            = var.username
  password            = var.password
  skip_final_snapshot = true

  vpc_security_group_ids = [var.vpc_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.this.name
}