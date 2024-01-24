# Create listener to Backend ALB
resource "aws_lb_listener" "this" {
  count             = var.create_ecs_service && local.enable_backend_alb ? 1 : 0
  load_balancer_arn = try(data.aws_lb.this[0].arn, null)
  protocol          = local.listener_protocol
  port              = var.listener_port

  default_action {
    type             = "forward"
    target_group_arn = local.enable_default_tg ? try(aws_lb_target_group.this[0].arn, null) : try(aws_lb_target_group.blue[0].arn, null)
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [default_action]
  }
}

# Add listener rule to Frontend ALB
resource "aws_lb_listener_rule" "this" {
  count        = var.create_ecs_service && local.enable_frontend_alb ? 1 : 0
  listener_arn = try(data.aws_lb_listener.front[0].arn, null)
  priority     = var.priority

  action {
    type             = "forward"
    target_group_arn = local.enable_default_tg ? try(aws_lb_target_group.this[0].arn, null) : try(aws_lb_target_group.blue[0].arn, null)
  }

  dynamic "condition" {
    for_each = length(var.alb_hosts) > 0 ? [1] : []
    content {
      host_header {
        values = var.alb_hosts
      }
    }
  }

  dynamic "condition" {
    for_each = length(var.alb_paths) > 0 ? [1] : []
    content {
      path_pattern {
        values = var.alb_paths
      }
    }
  }

  dynamic "condition" {
    for_each = length(var.source_ip) > 0 ? [1] : []
    content {
      source_ip {
        values = var.source_ip
      }
    }
  }

  lifecycle {
    ignore_changes = [action]
  }

}
