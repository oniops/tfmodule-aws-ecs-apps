locals {
  task_definition_name = format("%s-td", local.app_name)

  logConfiguration = var.enable_cloudwatch_log_group ? length(keys(var.logConfiguration.options)) > 0 ? var.logConfiguration : {
    logDriver = "awslogs"
    options   = {
      awslogs-group         = local.cloudwatch_log_group_name
      awslogs-region        = var.context.region
      awslogs-stream-prefix = local.service_name
    }
  } : {
    logDriver = null
    options   = {}
  }

  portMappings = length(var.portMappings) > 0 ? var.portMappings : [
    {
      containerPort = var.task_port
      protocol      = "tcp"
    }
  ]

  container_definition = {
    name         = local.service_name
    image        = aws_ecr_repository.this.repository_url
    essential    = var.essential
    memory       = var.task_memory
    cpu          = var.task_cpu
    command      = toset(var.command)
    portMappings = toset(local.portMappings)
    environment  = toset(var.environments)
    secrets      = toset(var.secrets)
    ulimits      = toset(var.ulimits)
    mountPoints  = toset(var.mountPoints)

    logConfiguration = local.logConfiguration

    linuxParameters = {
      initProcessEnabled = var.initProcessEnabled
    }
  }

  container_definition_json = jsonencode(local.container_definition)
}


resource "aws_ecs_task_definition" "this" {
  count                    = var.delete_service && var.delete_task_definition ? 0 : 1
  family                   = local.task_definition_name
  requires_compatibilities = var.requires_compatibilities
  network_mode             = "awsvpc"
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  container_definitions    = "[${local.container_definition_json}]"

  tags = merge(
    local.tags,
    var.tags,
    { Name = local.task_definition_name }
  )
}
