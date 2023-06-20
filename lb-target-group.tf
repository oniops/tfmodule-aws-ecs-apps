locals {
  tg_name_blue       = format("%s-%s-blue-tg", var.context.project, var.app_name)
  tg_name_green      = format("%s-%s-green-tg", var.context.project, var.app_name)
  tg_name_default    = format("%s-%s-tg", var.context.project, var.app_name)
  load_balancer_type = local.enable_code_deploy ? try(data.aws_lb.this[0].load_balancer_type, "application") : "application"
  listener_protocol  = local.load_balancer_type == "application" ? "HTTP" : "TCP"
  health_check_path  = local.load_balancer_type == "application" ? var.health_check_path : ""
  enable_default_tg  = local.enable_load_balancer && var.enable_service_connect && !local.enable_code_deploy
}

resource "aws_lb_target_group" "this" {
  count       = local.enable_default_tg ? 1 : 0
  name        = local.tg_name_default
  port        = var.task_port
  protocol    = local.listener_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = var.health_check_path
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

  dynamic "stickiness" {
    for_each = var.stickiness_enabled ? ["true"] : []
    content {
      enabled = var.stickiness_enabled
      type    = var.stickiness_type
    }
  }

  tags = merge(
    local.tags,
    { Name = local.enable_default_tg }
  )

}

resource "aws_lb_target_group" "blue" {
  count       = local.enable_code_deploy ? 1 : 0
  name        = local.tg_name_blue
  port        = var.task_port
  protocol    = local.listener_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = var.health_check_path
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

  dynamic "stickiness" {
    for_each = var.stickiness_enabled ? ["true"] : []
    content {
      enabled = var.stickiness_enabled
      type    = var.stickiness_type
    }
  }

  tags = merge(
    local.tags,
    { Name = local.tg_name_blue }
  )

}

resource "aws_lb_target_group" "green" {
  count       = local.enable_code_deploy ? 1 : 0
  name        = local.tg_name_green
  port        = var.task_port
  protocol    = local.listener_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = local.health_check_path
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

  dynamic "stickiness" {
    for_each = var.stickiness_enabled ? ["true"] : []
    content {
      enabled = var.stickiness_enabled
      type    = var.stickiness_type
    }
  }

  tags = merge(local.tags,
    {
      Name = local.tg_name_green
    }
  )

}
