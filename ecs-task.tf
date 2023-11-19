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
      name          = var.app_name
    }
  ]

  container_definition = [
    {
      name         = local.container_name
      image        = local.create_ecr_repository ? try(aws_ecr_repository.this[0].repository_url, null) : local.repository_url
      essential    = var.essential
      memory       = var.task_memory
      cpu          = var.task_cpu
      command      = toset(var.command)
      portMappings = toset(local.portMappings)
      environment  = toset(var.environments)
      secrets      = toset(var.secrets)
      ulimits      = toset(var.ulimits)
      mountPoints  = toset(var.mountPoints)
      readonlyRootFilesystem = var.readonlyRootFilesystem

      ephemeral_storage = {
        size_in_gib = var.task_ephemeral_storage
      }

      logConfiguration = local.logConfiguration

      linuxParameters = {
        initProcessEnabled = var.initProcessEnabled
      }
    }
  ]

}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
resource "aws_ecs_task_definition" "this" {
  family                   = local.task_definition_name
  requires_compatibilities = var.requires_compatibilities
  network_mode             = "awsvpc"
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  container_definitions    = jsonencode(local.container_definition)

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#runtime_platform
  dynamic "runtime_platform" {
    for_each = var.cpu_architecture == "ARM64" ? [1] : []
    content {
      operating_system_family = var.operating_system_family
      cpu_architecture        = var.cpu_architecture
    }
  }

  tags = merge(
    local.tags,
    var.tags,
    { Name = local.task_definition_name }
  )
}
