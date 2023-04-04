resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]
}