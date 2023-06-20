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

data "aws_ecs_cluster" "this" {
  cluster_name = "${local.name_prefix}-ecs"
}

data "aws_ecs_service" "this" {
  cluster_arn  = data.aws_ecs_cluster.this.arn
  service_name = "${local.name_prefix}-portal-api-ecss"
}

output "ecs_service_info" {
  value = {
    cluster_name = data.aws_ecs_cluster.this.cluster_name
    service_name = data.aws_ecs_service.this.service_name
  }
}

module "cpu_high" {
  source                   = "../../modules/step-scaling/"
  cluster_name             = data.aws_ecs_cluster.this.cluster_name
  service_name             = data.aws_ecs_service.this.service_name
  step_scaling_name        = "CpuHigh"
  adjustment_type          = "ChangeInCapacity"
  comparison_operator      = "GreaterThanThreshold"
  metric_aggregation_type  = "Average"
  step_adjustment          = [
    {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 15.0
      scaling_adjustment          = 0
    },
    {
      metric_interval_lower_bound = 15.0
      metric_interval_upper_bound = 25.0
      scaling_adjustment          = 1
    },
    {
      metric_interval_lower_bound = 25.0
      metric_interval_upper_bound = null
      scaling_adjustment          = 1
    },
  ]

  # for alarm metric
  metric_name        = "CPUUtilization"
  statistic          = "Average"
  threshold          = 60.0
  period             = 60
  evaluation_periods = 2

  tags = local.tags

}


module "cpu_low" {
  source                   = "../../modules/step-scaling/"
  cluster_name             = data.aws_ecs_cluster.this.cluster_name
  service_name             = data.aws_ecs_service.this.service_name
  step_scaling_name        = "MemoryLow"
  adjustment_type          = "ChangeInCapacity"
  metric_aggregation_type  = "Average"
  step_adjustment          = [
    # 5% ~ 10% = 0
    {
      metric_interval_lower_bound = -5.0
      metric_interval_upper_bound = 0.0
      scaling_adjustment          = 0
    },
    # 0% ~ 5% = -1
    {
      metric_interval_lower_bound = null
      metric_interval_upper_bound = -5.0
      scaling_adjustment          = -1
    },
  ]

  # for alarm metric
  metric_name         = "MemoryUtilization"
  comparison_operator = "LessThanThreshold"
  threshold           = 10.0
  period              = 60
  evaluation_periods  = 2
  statistic           = "Average"

  tags = local.tags

}
