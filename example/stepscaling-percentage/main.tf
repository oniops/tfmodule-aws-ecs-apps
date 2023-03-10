module "ctx" {
  source  = "../context/"
  context = {
    project     = "sea"
    region      = "ap-southeast-1"
    environment = "Production"
    department  = "OpsNow"
    owner       = "aaron.ko@bespinglobal.com"
    customer    = "BGSEA"
    domain      = "opsnow.asia"
    pri_domain  = "backend.opsnow.com"
  }
}

locals {
  app_name           = "banana"
  project            = module.ctx.project
  name_prefix        = module.ctx.name_prefix
  tags               = module.ctx.tags
  ecs_task_role_name = format("%s%s", local.project, replace(title( format("%s-EcsTaskRole", local.app_name) ), "-", "" ))
  sg_name            = format("%s-%s-sg", local.name_prefix, local.app_name)
}

resource "aws_iam_role" "task_role" {
  name               = local.ecs_task_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = merge(local.tags, { Name = local.ecs_task_role_name })
}

resource "aws_security_group" "this" {
  name   = local.sg_name
  vpc_id = data.aws_vpc.this.id
  tags   = merge(local.tags, { Name = local.sg_name })
}

module "apple" {
  # source  = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-ecs-apps.git"
  source  = "../../"
  context = module.ctx.context

  cluster_name             = format("%s-ecs", local.name_prefix)
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  app_name                 = local.app_name
  task_cpu                 = 256
  task_memory              = 512
  task_port                = 8080
  listener_port            = 8088
  desired_count            = 1
  environments             = []
  retention_in_days        = 90
  task_role_arn            = aws_iam_role.task_role.arn
  #
  vpc_id                   = data.aws_vpc.this.id
  subnets                  = data.aws_subnets.app.ids
  backend_alb_name         = format("%s-backend-alb", local.name_prefix)
  security_group_ids       = [aws_security_group.this.id]
  enable_service_discovery = false

  depends_on = [aws_iam_role.task_role]
}

module "cpu_high" {
  source                   = "../../modules/step-scaling/"
  cluster_name             = module.apple.ecs_cluster_name
  service_name             = module.apple.ecs_service_name
  step_scaling_name        = "CpuHigh"
  adjustment_type          = "PercentChangeInCapacity"
  metric_aggregation_type  = "Average"
  min_adjustment_magnitude = 1
  step_adjustment          = [
    # 60 % ~ 70% = no weight
    {
      metric_interval_lower_bound = 0.0
      metric_interval_upper_bound = 10.0
      scaling_adjustment          = 0
    },
    # 70 % ~ 75% = 10% scale-out
    {
      metric_interval_lower_bound = 10.0
      metric_interval_upper_bound = 15.0
      scaling_adjustment          = 10.0
    },
    # 75 % ~ 85% = 20% scale-out
    {
      metric_interval_lower_bound = 15.0
      metric_interval_upper_bound = 25.0
      scaling_adjustment          = 20.0
    },
    # 85% ~ = 30% scale-out
    {
      metric_interval_lower_bound = 25.0
      metric_interval_upper_bound = null
      scaling_adjustment          = 30.0
    },
  ]

  # for alarm metric
  metric_name        = "CPUUtilization"
  statistic          = "Average"
  threshold          = 60.0
  period             = 120
  evaluation_periods = 2

  tags = local.tags

  depends_on = [module.apple]
}


module "cpu_low" {
  source                   = "../../modules/step-scaling/"
  cluster_name             = module.apple.ecs_cluster_name
  service_name             = module.apple.ecs_service_name
  step_scaling_name        = "CpuLow"
  adjustment_type          = "ChangeInCapacity"
  metric_aggregation_type  = "Average"
  min_adjustment_magnitude = 1
  step_adjustment          = [
    # 30% ~ 40% = -1
    {
      metric_interval_lower_bound = -10.0
      metric_interval_upper_bound = 0.0
      scaling_adjustment          = -1
    },
    # 20% ~ 30% = -1
    {
      metric_interval_lower_bound = -20.0
      metric_interval_upper_bound = -10.0
      scaling_adjustment          = -1
    },
    #  0% ~ 20% = -1
    {
      metric_interval_lower_bound = null
      metric_interval_upper_bound = -20
      scaling_adjustment          = -1
    },
  ]

  # for alarm metric
  metric_name         = "CPUUtilization"
  comparison_operator = "LessThanThreshold"
  threshold           = 40.0
  period              = 60
  evaluation_periods  = 2
  statistic           = "Average"

  tags = local.tags

  depends_on = [module.apple]
}
