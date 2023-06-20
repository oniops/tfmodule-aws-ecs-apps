locals {
  enable_backend_alb = var.enable_code_deploy && var.backend_alb_name != null && var.frontend_alb_name == null
}

# Create listener to Backend ALB
resource "aws_lb_listener" "this" {
  count             = var.backend_alb_name != null && var.frontend_alb_name == null ? 1 : 0
  load_balancer_arn = data.aws_lb.this.arn
  protocol          = local.listener_protocol
  port              = var.listener_port

  default_action {
    type             = "forward"
    target_group_arn = try(aws_lb_target_group.blue[0].arn, null)
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}

# Add listener rule to Frontend ALB
resource "aws_lb_listener_rule" "this" {
  count        = var.frontend_alb_name != null && var.backend_alb_name == null ? 1 : 0
  listener_arn = try(data.aws_lb_listener.front[0].arn, null)

  action {
    type             = "forward"
    target_group_arn = try(aws_lb_target_group.blue[0].arn, null)
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

  lifecycle {
    ignore_changes = [action]
  }
}
