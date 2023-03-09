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
  app_name           = "apple"
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


#CloudWatch 평균 CPU 임계값 50% 를 기준으로, 최소 2회 연속 1분간의 평가 기간에 Auto Scaling 그룹의 크기를 확장하는 경보를 생성하고,
#여기에 대응하는 Auto-Scaling 정책을 아래와 같이 정의할 수 있습니다.
#
#- Metric 평균 값이 50% 이상이고 65% 미만인 경우 인스턴스 수를 조정하지 않습니다.
#- Metric 평균 값이 65% 이상이고 75% 미만인 경우 인스턴스 수를 2개 확장합니다.
#- Metric 평균 값이 75% 이상이면 인스턴스 수를 4개 확장합니다.


module "apple" {
  source  = "../../"
  context = module.ctx.context

  cluster_name             = format("%s-ecs", local.name_prefix)
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  app_name                 = local.app_name
  listener_port            = 8088
  desired_count            = 1
  task_role_arn            = aws_iam_role.task_role.arn
  #
  vpc_id                   = data.aws_vpc.this.id
  subnets                  = data.aws_subnets.app.ids
  backend_alb_name         = format("%s-backend-alb", local.name_prefix)
  security_group_ids       = [aws_security_group.this.id]
  enable_service_discovery = false
  #
  # ASG StepScaling policy
  step_scaling_name        = "cpu"
  metric_name              = "CPUUtilization"
  threshold                = 50.0
  period                   = 60
  evaluation_periods       = 2
  statistic                = "Average"
  adjustment_type          = "ChangeInCapacity"
  metric_aggregation_type  = "Average"
  min_adjustment_magnitude = 1
  step_adjustment          = [
    {
      metric_interval_lower_bound = -20.0
      metric_interval_upper_bound = 10.0
      scaling_adjustment          = 0
    },
    {
      metric_interval_lower_bound = 10.0
      metric_interval_upper_bound = 25.0
      scaling_adjustment          = 1
    },
    {
      metric_interval_lower_bound = 25.0
      metric_interval_upper_bound = null
      scaling_adjustment          = 1
    },
    {
      metric_interval_lower_bound = -30
      metric_interval_upper_bound = -20
      scaling_adjustment          = -1
    },
    {
      metric_interval_lower_bound = null
      metric_interval_upper_bound = -30
      scaling_adjustment          = -1
    },
  ]

  depends_on = [aws_iam_role.task_role]
}
