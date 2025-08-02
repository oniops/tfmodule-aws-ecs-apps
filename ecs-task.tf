locals {
  task_definition_name = format("%s-td", local.app_name)

  logConfiguration = var.enable_cloudwatch_log_group ? length(keys(var.logConfiguration.options)) > 0 ? var.logConfiguration : {
    logDriver = "awslogs"
    options = {
      awslogs-group         = local.cloudwatch_log_group_name
      awslogs-region        = var.context.region
      awslogs-stream-prefix = local.service_name
    }
  } : null

  portMappings = length(var.portMappings) > 0 ? var.portMappings : var.task_port > 0 ? [
    {
      containerPort = var.task_port
      protocol      = "tcp"
      name          = var.app_name
    }
  ] : []

  container_definition = [
    {
      name                   = local.container_name
      image                  = local.create_ecr_repository ? try(aws_ecr_repository.this[0].repository_url, null) : local.repository_url
      essential              = var.essential
      memory                 = var.task_memory
      cpu                    = var.task_cpu
      command                = toset(var.command)
      portMappings           = toset(local.portMappings)
      environment            = toset(var.environments)
      secrets                = toset(var.secrets)
      ulimits                = toset(var.ulimits)
      mountPoints            = toset(var.mountPoints)
      readonlyRootFilesystem = var.readonlyRootFilesystem
      repositoryCredentials  = var.repositoryCredentials

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

  dynamic "volume" {
    for_each = var.volume
    content {
      name      = volume.value.name
      host_path = try(volume.value.host_path, "")

      dynamic "docker_volume_configuration" {
        for_each = try(volume.value.docker_volume_configuration, null) != null ? [volume.value.docker_volume_configuration] : []
        content {
          autoprovision = docker_volume_configuration.value.autoprovision
          driver        = docker_volume_configuration.value.driver
          driver_opts   = docker_volume_configuration.value.driver_opts
          labels        = docker_volume_configuration.value.labels
          scope         = docker_volume_configuration.value.scope
        }
      }

      dynamic "efs_volume_configuration" {
        for_each = try(volume.value.efs_volume_configuration, null) != null ? [volume.value.efs_volume_configuration] : []
        content {
          file_system_id = efs_volume_configuration.value.file_system_id
          root_directory = efs_volume_configuration.value.root_directory
        }
      }
    }
  }

  tags = merge(local.tags,
    var.tags,
    {
      Name = local.task_definition_name
    })
}
