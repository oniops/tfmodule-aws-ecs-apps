locals {
  account_id       = data.aws_caller_identity.current.account_id
  alb_listener_arn = var.backend_alb_name != null  ? local.backend_alb_listener_arn : local.frontend_alb_listener_arn
}

resource "aws_codedeploy_app" "this" {
  count            = var.delete_service ? 0 : 1
  compute_platform = "ECS"
  name             = format("%s-cd", local.service_name)
  tags             = merge(local.tags, { Name = format("%s-cd", local.service_name) })
}

resource "aws_codedeploy_deployment_group" "this" {
  count                  = var.delete_service ? 0 : 1
  app_name               = concat( aws_codedeploy_app.this.*.name, [""] )[0]
  deployment_group_name  = format("%s-cdg", local.service_name)
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = "arn:aws:iam::${local.account_id}:role/AWSCodeDeployRoleForECS"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.deploy_wait_time
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.cluster_name
    service_name = local.service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [local.alb_listener_arn]
      }
      target_group {
        name = aws_lb_target_group.blue.name
      }
      target_group {
        name = aws_lb_target_group.green.name
      }
    }
  }

  depends_on = [
    aws_ecs_service.this
  ]
}
