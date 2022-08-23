locals {
  backend_alb_listener_arn  = concat(aws_lb_listener.this.*.arn, [""])[0]
  frontend_alb_listener_arn = concat(data.aws_lb_listener.front.*.arn, [""])[0]
}

# Create listener to Backend ALB
resource "aws_lb_listener" "this" {
  count             = var.backend_alb_name != null && var.frontend_alb_name == null ? 1 : 0
  load_balancer_arn = data.aws_lb.this.arn
  protocol          = local.listener_protocol
  port              = var.listener_port

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}

# Add listener rule to Frontend ALB
resource "aws_lb_listener_rule" "this" {
  count        = var.frontend_alb_name != null && var.backend_alb_name == null ? 1 : 0
  listener_arn = concat(data.aws_lb_listener.front.*.arn, [""])[0]

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
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
