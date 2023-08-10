locals {
  # from context
  tags                          = var.context.tags
  name_prefix                   = var.context.name_prefix
  # ECS Service
  app_name                      = var.app_fullname == null ? format("%s-%s", local.name_prefix, var.app_name) : var.app_fullname
  service_name                  = format("%s-ecss", local.app_name)
  container_name                = format("%s-ecsc", local.app_name)
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
  repository_url            = var.repository != null ? var.repository.url : var.repository_url
  create_ecr_repository     = local.repository_url == null ? true : false
  # ELB
  enable_backend_alb        = var.enable_load_balancer && var.backend_alb_name != null && var.frontend_alb_name == null
  enable_frontend_alb       = var.enable_load_balancer && var.frontend_alb_name != null && var.backend_alb_name == null
  enable_load_balancer      = local.enable_backend_alb || local.enable_frontend_alb ? true : false
  backend_alb_listener_arn  = concat(aws_lb_listener.this.*.arn, [""])[0]
  frontend_alb_listener_arn = concat(data.aws_lb_listener.front.*.arn, [""])[0]
  # CodeDeploy
  enable_code_deploy        = var.enable_code_deploy && !var.enable_service_connect
  code_deploy_name          = format("%s-cd", local.app_name)
  code_deploy_grp_name      = format("%s-cdg", local.app_name)
  account_id                = data.aws_caller_identity.current.account_id
  alb_listener_arn          = var.backend_alb_name != null  ? local.backend_alb_listener_arn : local.frontend_alb_listener_arn
}
