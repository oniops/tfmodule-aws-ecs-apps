# stepscaling-basic

## ChangeInCapacity 기반 Step-Scaling 정책 구성

CloudWatch 평균 CPU 임계값 50% 를 기준으로, 최소 2회 연속 1분간의 평가 기간에 Auto Scaling 그룹의 크기를 확장하는 경보를 생성하고,
여기에 대응하는 Auto-Scaling 정책을 아래와 같이 정의할 수 있습니다.

- Metric 평균 값이 30% 이상이고 60% 미만인 경우 인스턴스 수를 조정하지 않습니다.
- Metric 평균 값이 60% 이상이고 75% 미만인 경우 인스턴스 수를 1개 확장 합니다.
- Metric 평균 값이 75% 이상이면 인스턴스 수를 1개 확장 합니다.
- Metric 평균 값이 20% 이상이고 30% 미만인 경우 인스턴스 수를 1개 축소 합니다.
- Metric 평균 값이 20% 미만인 경우 인스턴스 수를 1개 축소 합니다.

```
  # ASG StepScaling policy
  step_scaling_name        = "Cpu"
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
```
