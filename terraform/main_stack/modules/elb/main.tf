resource "aws_lb" "this" {
  name = "sm-load-balancer"

  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnets
  ip_address_type    = "ipv4"
}

resource "aws_lb_target_group" "this" {
  health_check {
    interval            = 30
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = 10
    unhealthy_threshold = 2
    healthy_threshold    = 5
  }

  name        = "sm-aline-target-group"
  port        = 8090
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 8090
  protocol          = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
}