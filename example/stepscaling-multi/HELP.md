# stepscaling-multi

## ChangeInCapacity 기반 Scale Out - CPU High

CloudWatch 평균 CPU 임계값 50% 를 기준으로, 최소 2회 연속 1분간의 평가 기간에 Auto Scaling 그룹의 크기를 확장하는 경보를 생성하고, 
여기에 대응하는 Auto-Scaling 정책을 아래와 같이 정의할 수 있습니다.

- Metric 평균 값이 50% 이상이고 65% 미만인 경우 인스턴스 수를 조정하지 않습니다.
- Metric 평균 값이 65% 이상이고 75% 미만인 경우 인스턴스 수를 2개 확장합니다.
- Metric 평균 값이 75% 이상이면 인스턴스 수를 4개 확장합니다.

```
  # ASG Scale-Out policy
  step_scaling_name        = "CpuHigh"
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
      metric_interval_lower_bound = 0.0
      metric_interval_upper_bound = 15.0
      scaling_adjustment          = 0
    },
    {
      metric_interval_lower_bound = 15.0
      metric_interval_upper_bound = 25.0
      scaling_adjustment          = 2
    },
    {
      metric_interval_lower_bound = 25.0
      metric_interval_upper_bound = null
      scaling_adjustment          = 4
    },
  ]
```

<br>

## ChangeInCapacity 기반 Scale In - CPU Low

CloudWatch 평균 CPU 임계값 40% 를 기준으로, 최소 2회 연속 1분간의 평가 기간에 Auto Scaling 그룹의 크기를 축소하는 경보를 생성하고,
여기에 대응하는 Auto-Scaling 정책을 아래와 같이 정의할 수 있습니다.


- Metric 평균 값이 30% 이상이고 40% 미만인 경우 인스턴스 수를 3개 축소 합니다.
- Metric 평균 값이 20% 이상이고 30% 미만인 경우 인스턴스 수를 2개 축소 합니다.
- Metric 평균 값이 20% 미만인 경우 인스턴스 수를 1개 축소 합니다.

```
  # ASG Scale-In policy
  scaledown_step_scaling_name        = "CpuLow"
  scaledown_metric_name              = "CPUUtilization"
  scaledown_threshold                = 40.0
  scaledown_period                   = 60
  scaledown_evaluation_periods       = 2
  scaledown_statistic                = "Average"
  scaledown_adjustment_type          = "ChangeInCapacity"
  scaledown_metric_aggregation_type  = "Average"
  scaledown_min_adjustment_magnitude = 1
  scaledown_step_adjustment          = [
    {
      metric_interval_lower_bound = -10.0
      metric_interval_upper_bound = 0.0
      scaling_adjustment          = -3
    },
    {
      metric_interval_lower_bound = -20.0
      metric_interval_upper_bound = -10.0
      scaling_adjustment          = -2
    },
    {
      metric_interval_lower_bound = null
      metric_interval_upper_bound = -20
      scaling_adjustment          = -1
    },
  ]
```


<br>

### ECS with Multiple Step-Scaling
ECS 애플리케이션 서비스 구성에서 Scale-Out 및 Scale-In 을 한꺼번에 설정하는 Step-Scaling 정책은 다음과 같습니다. 

```
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
  #
  #
  # ASG Scale-Out policy
  step_scaling_name        = "CpuHigh"
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
      metric_interval_lower_bound = 0.0
      metric_interval_upper_bound = 15.0
      scaling_adjustment          = 0
    },
    {
      metric_interval_lower_bound = 15.0
      metric_interval_upper_bound = 25.0
      scaling_adjustment          = 2
    },
    {
      metric_interval_lower_bound = 25.0
      metric_interval_upper_bound = null
      scaling_adjustment          = 4
    },
  ]
  #
  # ASG Scale-In policy
  scaledown_step_scaling_name        = "CpuLow"
  scaledown_metric_name              = "CPUUtilization"
  scaledown_threshold                = 40.0
  scaledown_period                   = 60
  scaledown_evaluation_periods       = 2
  scaledown_statistic                = "Average"
  scaledown_adjustment_type          = "ChangeInCapacity"
  scaledown_metric_aggregation_type  = "Average"
  scaledown_min_adjustment_magnitude = 1
  scaledown_step_adjustment          = [
    {
      metric_interval_lower_bound = -10.0
      metric_interval_upper_bound = 0.0
      scaling_adjustment          = -3
    },
    {
      metric_interval_lower_bound = -20.0
      metric_interval_upper_bound = -10.0
      scaling_adjustment          = -2
    },
    {
      metric_interval_lower_bound = null
      metric_interval_upper_bound = -20
      scaling_adjustment          = -1
    },
  ]

  depends_on = [aws_iam_role.task_role]
}
```
 

 
