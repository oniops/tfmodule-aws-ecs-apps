locals {
  namespace_domain_name = var.namespace_domain_name != null ? var.namespace_domain_name : var.context.pri_domain
}

data "aws_caller_identity" "current" {}

data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_name
}

data "aws_lb" "this" {
  count = local.enable_load_balancer ? 1 : 0
  name  = var.backend_alb_name != null ? var.backend_alb_name : var.frontend_alb_name
}

data "aws_lb_listener" "front" {
  count             = local.enable_code_deploy && var.frontend_alb_name != null ? 1 : 0
  load_balancer_arn = try(data.aws_lb.this[0].arn, null)
  port              = 443
}

data "aws_service_discovery_dns_namespace" "dns" {
  count = var.enable_service_discovery ? 1 : 0
  name  = local.namespace_domain_name
  type  = "DNS_PRIVATE"
}

data "aws_service_discovery_http_namespace" "ans" {
  count = var.enable_service_connect ? 1 : 0
  name  = local.namespace_domain_name
}
