locals {
  task_definition_family   = concat( aws_ecs_task_definition.this.*.family, [""])[0]
  task_definition_revision = concat( aws_ecs_task_definition.this.*.revision, [""])[0]
  task_definition          = format("%s:%s", local.task_definition_family, local.task_definition_revision )
  deployment_controller    = var.enable_service_connect ? "ECS" : var.deployment_controller
  enable_default_tg        = local.deployment_controller == "ECS" ? true : false
}

resource "aws_ecs_service" "this" {
  count                             = var.create_ecs_service ? 1 : 0
  name                              = local.service_name
  cluster                           = data.aws_ecs_cluster.this.id
  task_definition                   = local.task_definition
  desired_count                     = var.desired_count
  launch_type                       = var.launch_type
  scheduling_strategy               = var.scheduling_strategy
  health_check_grace_period_seconds = local.enable_load_balancer ? var.health_check_grace_period : null
  enable_ecs_managed_tags           = var.enable_ecs_managed_tags
  enable_execute_command            = var.enable_execute_command

  dynamic "capacity_provider_strategy" {
    # Set by task set if deployment controller is external
    for_each = {for k, v in var.capacity_provider_strategy : k => v if var.capacity_provider_strategy != null}

    content {
      base              = try(capacity_provider_strategy.value.base, null)
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = try(capacity_provider_strategy.value.weight, null)
    }
  }

  deployment_controller {
    type = local.enable_load_balancer ? local.deployment_controller : null
  }

  dynamic "load_balancer" {
    for_each = local.enable_load_balancer ? [1] : []
    content {
      container_name   = local.container_name
      container_port   = var.task_port
      target_group_arn = local.enable_default_tg ?  try(aws_lb_target_group.this[0].arn, null) : try(aws_lb_target_group.blue[0].arn, null)
    }
  }

  network_configuration {
    assign_public_ip = var.assign_public_ip
    subnets          = toset(var.subnets)
    security_groups  = toset(var.security_group_ids)
  }

  propagate_tags = var.propagate_tags

  dynamic "service_registries" {
    for_each = var.enable_service_discovery ? [1] : []
    content {
      registry_arn   = concat(aws_service_discovery_service.this.*.arn, [""])[0]
      container_name = local.service_name
      # container_port = var.task_port
    }
  }

  dynamic "service_connect_configuration" {
    for_each = var.enable_service_connect ? [local.service_connect_configuration] : []

    content {
      enabled   = true
      namespace = try(data.aws_service_discovery_http_namespace.ans[0].arn, null)

      dynamic "service" {
        for_each = try([service_connect_configuration.value.service], [])

        content {
          dynamic "client_alias" {
            for_each = try([service.value.client_alias], [])
            content {
              dns_name = try(client_alias.value.dns_name, null)
              port     = client_alias.value.port
            }
          }
          port_name             = service.value.port_name
          discovery_name        = try(service.value.discovery_name, null)
          ingress_port_override = try(service.value.ingress_port_override, null)
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      load_balancer,
      desired_count
    ]
  }

  tags = merge(local.tags,
    var.tags,
    var.ecs_tags,
    { Name = local.service_name }
  )

  depends_on = [
    aws_ecr_repository.this,
    aws_ecs_task_definition.this,
  ]
}