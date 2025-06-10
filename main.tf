locals {
  # from context
  account_id                    = var.context.account_id
  name_prefix                   = var.context.name_prefix
  tags                          = var.context.tags
  # ECS Service
  app_name                      = var.fullname == null ? format("%s-%s", local.name_prefix, var.app_name) : var.fullname
  service_name                  = var.service_name != null ? var.service_name :  "${local.app_name}-ecss"
  container_name                = var.container_name != null ? var.container_name : "${local.app_name}-ecsc"
  cloudwatch_log_group_name     = var.cloudwatch_log_group_name != null ? var.cloudwatch_log_group_name : format("/ecs/%s", local.service_name)
  service_connect_configuration = var.service_connect_configuration != null ? var.service_connect_configuration : {
    service = {
      port_name    = var.app_name
      client_alias = {
        port = var.task_port
      }
    }
  }
  # ECR
  create_ecr_repository     = var.repository != null || var.repository_url != null ? false : true
  repository_url            = var.repository != null ? var.repository.url : var.repository_url
  # ELB
  enable_backend_alb        = var.enable_load_balancer && var.backend_alb_name != null && var.frontend_alb_name == null
  enable_frontend_alb       = var.enable_load_balancer && var.frontend_alb_name != null && var.backend_alb_name == null
  enable_load_balancer      = local.enable_backend_alb || local.enable_frontend_alb ? true : false
  backend_alb_listener_arn  = concat(aws_lb_listener.this.*.arn, [""])[0]
  frontend_alb_listener_arn = concat(data.aws_lb_listener.front.*.arn, [""])[0]
  alb_listener_arn          = var.backend_alb_name != null  ? local.backend_alb_listener_arn : local.frontend_alb_listener_arn
}
