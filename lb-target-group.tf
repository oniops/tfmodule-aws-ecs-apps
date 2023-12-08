locals {
  tg_name_blue          = format("%s-%s-blue-tg", var.context.project, var.app_name)
  tg_name_green         = format("%s-%s-green-tg", var.context.project, var.app_name)
  tg_name_default       = format("%s-%s-tg", var.context.project, var.app_name)
  load_balancer_type    = try(data.aws_lb.this[0].load_balancer_type, "application")
  listener_protocol     = local.load_balancer_type == "application" ? "HTTP" : "TCP"
  health_check_protocol = var.health_check_protocol != null ? var.health_check_protocol : local.listener_protocol
  health_check_path     = local.health_check_protocol == "TCP" ? "" : var.health_check_path
}

resource "aws_lb_target_group" "this" {
  count       = var.create_ecs_service && local.enable_load_balancer && local.deployment_controller == "ECS" ? 1 : 0
  name        = local.tg_name_default
  port        = var.task_port
  protocol    = local.listener_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    protocol            = local.health_check_protocol
    path                = var.health_check_path
    matcher             = var.health_check_matcher
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
    { Name = local.tg_name_default }
  )

}

resource "aws_lb_target_group" "blue" {
  count       = var.create_ecs_service && local.enable_load_balancer && local.deployment_controller == "CODE_DEPLOY" ? 1 : 0
  name        = local.tg_name_blue
  port        = var.task_port
  protocol    = local.listener_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    protocol            = local.health_check_protocol
    path                = var.health_check_path
    matcher             = var.health_check_matcher
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
  count       = var.create_ecs_service && local.enable_load_balancer && local.deployment_controller == "CODE_DEPLOY" ? 1 : 0
  name        = local.tg_name_green
  port        = var.task_port
  protocol    = local.listener_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    protocol            = local.health_check_protocol
    path                = local.health_check_path
    matcher             = var.health_check_matcher
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
