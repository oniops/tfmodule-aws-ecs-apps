data "aws_caller_identity" "current" {}

data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_name
}

data "aws_lb" "this" {
  name = var.backend_alb_name != null ? var.backend_alb_name : var.frontend_alb_name
}

data "aws_lb_listener" "front" {
  count = var.frontend_alb_name != null ? 1 : 0
  load_balancer_arn = data.aws_lb.this.arn
  port              = 443
}

