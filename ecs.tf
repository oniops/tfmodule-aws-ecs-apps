locals {
  app_name                  = var.app_fullname == null ? format("%s-%s", local.name_prefix, var.app_name) : var.app_fullname
  service_name              = format("%s-ecss", local.app_name)
  container_name            = format("%s-ecsc", local.app_name)
  cloudwatch_log_group_name = var.cloudwatch_log_group_name != null ? var.cloudwatch_log_group_name : format("/ecs/%s", local.service_name)
  task_definition_family    = concat( aws_ecs_task_definition.this.*.family, [""])[0]
  task_definition_revision  = concat( aws_ecs_task_definition.this.*.revision, [""])[0]
  task_definition           = local.task_definition_family # format("%s:%s", local.task_definition_family, local.task_definition_revision )
  enable_load_balancer      = var.enable_load_balancer && var.task_port > 0 ? true : false

  # from context
  tags        = var.context.tags
  name_prefix = var.context.name_prefix
}

resource "aws_ecs_service" "this" {
  count                             = var.delete_service ? 0 : 1
  name                              = local.service_name
  cluster                           = data.aws_ecs_cluster.this.id
  task_definition                   = local.task_definition
  desired_count                     = var.desired_count
  launch_type                       = var.launch_type
  scheduling_strategy               = var.scheduling_strategy
  health_check_grace_period_seconds = var.health_check_grace_period
  enable_ecs_managed_tags           = var.enable_ecs_managed_tags
  enable_execute_command            = var.enable_execute_command

  deployment_controller {
    type = var.deployment_controller
  }

  dynamic "load_balancer" {
    for_each = local.enable_load_balancer ? [1] : []
    content {
      container_name   = local.container_name
      container_port   = var.task_port
      target_group_arn = aws_lb_target_group.blue.arn
    }
  }

  network_configuration {
    assign_public_ip = var.assign_public_ip
    subnets          = toset(var.subnets)
    security_groups  = toset(var.security_group_ids)
  }

  propagate_tags = var.propagate_tags

  service_registries {
    registry_arn   = concat(aws_service_discovery_service.this.*.arn, [""])[0]
    container_name = local.service_name
    # container_port = var.task_port
  }

  lifecycle {
    ignore_changes = [
      load_balancer,
      desired_count
    ]
  }

  tags = merge(var.tags,
    { Name = local.service_name }
  )

  depends_on = [
    aws_ecr_repository.this,
    aws_ecs_task_definition.this,
  ]
}

