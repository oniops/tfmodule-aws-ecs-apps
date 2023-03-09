# stepscaling-percentage

## PercentChangeInCapacity 기반 Scale Out - CPU High

CloudWatch 평균 CPU 임계값 60% 를 기준으로, 최소 2회 연속 2분간의 평가 기간에 Auto Scaling 그룹의 크기를 확장하는 경보를 생성하고, 
여기에 대응하는 Auto-Scaling 정책을 아래와 같이 정의할 수 있습니다.

- Metric 평균 값이 60% 이상이고 75% 미만인 경우 인스턴스 수를 10% 늘립니다.
- Metric 평균 값이 75% 이상이고 85% 미만인 경우 인스턴스 수를 20% 늘립니다.
- Metric 평균 값이 85% 이상이면 인스턴스 수를 30% 늘립니다.


```
module "cpu_high" {
  source                   = "../../modules/step-scaling/"
  cluster_name             = module.apple.ecs_cluster_name
  service_name             = module.apple.ecs_service_name
  autoscale_policy_name    = "CpuHigh"
  adjustment_type          = "PercentChangeInCapacity"
  metric_aggregation_type  = "Average"
  min_adjustment_magnitude = 1
  step_adjustment          = [
    {
      metric_interval_lower_bound = 0.0
      metric_interval_upper_bound = 10.0
      scaling_adjustment          = 0
    },
    {
      metric_interval_lower_bound = 10.0
      metric_interval_upper_bound = 15.0
      scaling_adjustment          = 10.0
    },
    {
      metric_interval_lower_bound = 15.0
      metric_interval_upper_bound = 25.0
      scaling_adjustment          = 20.0
    },
    {
      metric_interval_lower_bound = 25.0
      metric_interval_upper_bound = null
      scaling_adjustment          = 30.0
    },
  ]

  # for alarm metric
  metric_name        = "CPUUtilization"
  evaluation_periods = 2
  period             = 120
  threshold          = 60.0
  statistic          = "Average"

}
```

`cpu_high` 모듈의 ECS Auto-Scaling 정책에서 Scaling 조정 타입은 `PercentChangeInCapacity` 을 기반으로 합니다.
만약, 현재 용량과 원하는 용량의 개수가 10 인 Auto Scaling 그룹이라면  

- CloudWatch 의 CPU 메트릭의 평균값의 차이가 나는 비율이  0 % ~ 10 % 구간은 Scaling 조정을 하지 않습니다.
- CloudWatch 의 CPU 메트릭의 평균값의 차이가 나는 비율이 10 % ~ 15 % 구간은 Scaling 조정을 현재 capacity 의 10 % 를 올립니다. 결과로 10 + round(10 * 0.10) = 11 개가 됩니다.
- CloudWatch 의 CPU 메트릭의 평균값의 차이가 나는 비율이 15 % ~ 25 % 구간은 Scaling 조정을 현재 capacity 의 20 % 를 올립니다. 결과로 11 + round(11 * 0.20) = 13 개가 됩니다.
- CloudWatch 의 CPU 메트릭의 평균값의 차이가 나는 비율이 25 % ~ 이상인 경우는 Scaling 조정을 현재 capacity 의 30 % 를 올립니다. 결과로 13 + round(13 * 0.30) = 17 개가 됩니다.


### Scale-Out - AWS CLI 예시 

위의 Scale-Out 정책을 AWS CLI 로 생성한다면 아래와 같습니다.

```
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name apple-asg  \
  --policy-name apple-step-scale-out-policy \
  --policy-type StepScaling \
  --adjustment-type PercentChangeInCapacity \
  --metric-aggregation-type Average \
  --step-adjustments MetricIntervalLowerBound=0.0,MetricIntervalUpperBound=10.0,ScalingAdjustment=0 \
                     MetricIntervalLowerBound=10.0,MetricIntervalUpperBound=15.0,ScalingAdjustment=10 \
                     MetricIntervalLowerBound=15.0,MetricIntervalUpperBound=25.0,ScalingAdjustment=20 \
                     MetricIntervalLowerBound=25.0,ScalingAdjustment=30 \
  --min-adjustment-magnitude 1
```


<br>


## PercentChangeInCapacity 기반 Scale In - CPU Low

CloudWatch 평균 CPU 임계값 40% 를 기준으로, 최소 2회 연속 1분간의 평가 기간에 Auto Scaling 그룹의 크기를 축소하는 경보를 생성하고,
여기에 대응하는 Auto-Scaling 정책을 아래와 같이 정의할 수 있습니다.


- Metric 평균 값이 30% 이상이고 40% 미만인 경우 인스턴스 수를 3개 축소 합니다.
- Metric 평균 값이 20% 이상이고 30% 미만인 경우 인스턴스 수를 2개 축소 합니다.
- Metric 평균 값이 20% 미만인 경우 인스턴스 수를 1개 축소 합니다.


```
module "cpu_low" {
  source                   = "../../modules/step-scaling/"
  cluster_name             = module.apple.ecs_cluster_name
  service_name             = module.apple.ecs_service_name
  autoscale_policy_name    = "CpuLow"
  adjustment_type          = "ChangeInCapacity"
  metric_aggregation_type  = "Average"
  min_adjustment_magnitude = 1
  step_adjustment          = [
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

  # for alarm metric
  metric_name        = "CPUUtilization"
  evaluation_periods = 2
  period             = 60
  threshold          = 40.0
  statistic          = "Average"
}

```

`cpu_low` 모듈의 ECS Auto-Scaling 정책에서 Scaling 조정 타입은 `ChangeInCapacity` 을 기반으로 합니다.
만약, 현재 용량과 원하는 용량의 개수가 10 인 Auto Scaling 그룹이라면

- CloudWatch 의 CPU 메트릭의 평균값의 차이가 나는 비율이   0 % ~ -10 % 구간은 Scaling 조정을 현재 capacity 에서 3개 축소 합니다. 결과로 10 - 3 = 7 개가 됩니다.
- CloudWatch 의 CPU 메트릭의 평균값의 차이가 나는 비율이 -10 % ~ -20 % 구간은 Scaling 조정을 현재 capacity 에서 2개 축소 합니다. 결과로  7 - 2 = 5 개가 됩니다.
- CloudWatch 의 CPU 메트릭의 평균값의 차이가 나는 비율이 -20 % 미만 구간은 Scaling 조정을 현재 capacity 에서 1개 축소합니다. 결과로 5 - 1 = 4 개가 됩니다.


### Scale-In - AWS CLI 예시

위의 Scale-In 정책을 AWS CLI 로 생성한다면 아래와 같습니다. 

```
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name apple-asg  \
  --policy-name apple-step-scale-in-policy \
  --policy-type StepScaling \
  --adjustment-type ChangeInCapacity \
  --step-adjustments MetricIntervalUpperBound=0.0,MetricIntervalLowerBound=-10.0,ScalingAdjustment=-3 \
                   MetricIntervalUpperBound=-10.0,MetricIntervalLowerBound=-20.0,ScalingAdjustment=-2 \
                   MetricIntervalUpperBound=-20.0,ScalingAdjustment=-1 \
  --min-adjustment-magnitude 1
```
