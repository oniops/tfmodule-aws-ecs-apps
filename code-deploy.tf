locals {
  code_deploy_name          = format("%s-cd", local.app_name)
  code_deploy_grp_name      = format("%s-cdg", local.app_name)
}

resource "aws_codedeploy_app" "this" {
  count            = var.create_ecs_service && local.deployment_controller == "CODE_DEPLOY" ? 1 : 0
  compute_platform = "ECS"
  name             = local.code_deploy_name
  tags             = merge(local.tags,
    { Name = local.code_deploy_name }
  )
}

resource "aws_codedeploy_deployment_group" "this" {
  count                  = var.create_ecs_service && local.deployment_controller == "CODE_DEPLOY" ? 1 : 0
  app_name               = concat( aws_codedeploy_app.this.*.name, [""] )[0]
  deployment_group_name  = local.code_deploy_grp_name
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
        name = try(aws_lb_target_group.blue[0].name, null)
      }
      target_group {
        name = try(aws_lb_target_group.green[0].name, null)
      }
    }
  }

  tags = merge(local.tags,
    { Name = local.code_deploy_grp_name }
  )

  depends_on = [
    aws_ecs_service.this
  ]
}
