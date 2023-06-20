### ECS Cluster
variable "cluster_name" {
  description = "ecs cluster name"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume."
  type        = string
}

variable "requires_compatibilities" {
  description = "requires_compatibilities"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}


### ECS Service
variable "app_fullname" {
  description = "ECS application service fullname"
  type        = string
  default     = null
}

variable "app_name" {
  description = "application name"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services."
  type        = string
}


# ECS Tasks

variable "essential" {
  description = "essential"
  type        = bool
  default     = true
}

variable "task_cpu" {
  description = "cpu"
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "memory"
  type        = number
  default     = 1024
}

variable "task_port" {
  description = "application container port"
  type        = number
  default     = 8080
}

variable "command" {
  description = "run command"
  type        = list(string)
  default     = []
}

variable "portMappings" {
  description = "port_mappings"
  type        = list(any)
  default     = []
  /*
  port_mappings = [
    {
      "protocol": "tcp",
      "containerPort": 8"
    }
  ]
  */
}

variable "environments" {
  description = "environment variables"
  type        = list(any)
  default     = []
  /*
    environments = [
      {
        name = "spring.profiles.active"
        value = "dev"
      }
    ]
  */
}

# aws ssm get-parameter --name /ALERTNOW/ACCESSKEY
variable "secrets" {
  description = "secret variables"
  type        = list(any)
  default     = []
  /*
    secrets = [
      {
        name = "aws.credentials.accessKey"
        valueFrom = "arn:aws:ssm:<aws_region>:<aws_account>:parameter/<your_project>/<your_module>/accessKey"
      },
      {
        name = "aws.credentials.secretKey"
        valueFrom = "arn:aws:ssm:<aws_region>:<aws_account>:parameter/<your_project>/<your_module>/secretKey"
      }
    ]
  */
}

variable "ulimits" {
  description = "ulimits"
  type        = list(any)
  default     = []
  /*
    ulimits = [
      {
        "name": "nofile",
        "softLimit": 1000000,
        "hardLimit": 1000000
      }
    ]
  */
}

variable "mountPoints" {
  description = "mountPoints"
  type        = list(any)
  default     = []
}

variable "logConfiguration" {
  description = "logConfiguration"
  type        = object({
    logDriver = string
    options   = map(string)
  })
  default = {
    logDriver = null
    options   = {}
  }
  /*
  {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.service_name}"
          awslogs-region        = var.region
          awslogs-stream-prefix = local.service_name
        }
      }
  */
}

variable "initProcessEnabled" {
  description = "initProcessEnabled"
  type        = bool
  default     = true
}


variable "cloudwatch_log_group_name" {
  description = "Cloudwatch log group name"
  type        = string
  default     = null
}

variable "enable_cloudwatch_log_group" {
  description = "create cloudwatch log group"
  type        = bool
  default     = true
}

variable "retention_in_days" {
  description = "cloudwatch log group retention_in_days"
  type        = number
  default     = 90
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# ECS Service

variable "launch_type" {
  description = "launch_type of ECS Service"
  type        = string
  default     = "FARGATE"
}

variable "scheduling_strategy" {
  description = "scheduling_strategy of ECS Service"
  type        = string
  default     = "REPLICA"
  /*
  REPLICA | DAEMON
  */
}

variable "health_check_grace_period" {
  description = "health_check_grace_period_seconds of ECS Service"
  type        = number
  default     = 120
}

variable "desired_count" {
  description = "desired_count of ECS Service"
  type        = number
  default     = 1
}

variable "enable_ecs_managed_tags" {
  description = "enable_ecs_managed_tags of ECS Service"
  type        = bool
  default     = true
}

variable "enable_execute_command" {
  description = "enable_execute_command of ECS Service"
  type        = bool
  default     = true
}

variable "health_check_grace_period_seconds" {
  description = "health_check_grace_period_seconds of ECS Service"
  type        = number
  default     = 360
}

variable "deployment_controller" {
  description = "deployment_controller of ECS Service"
  type        = string
  default     = "CODE_DEPLOY"
  /*
  CODE_DEPLOY | ECS
  */
}

variable "enable_load_balancer" {
  description = "Enable Load Balancer of ECS Service"
  type        = bool
  default     = true
}

variable "assign_public_ip" {
  description = "assign_public_ip of ECS Service"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "subnets of ECS Service"
  type        = list(string)
}

variable "security_group_ids" {
  description = "security_group_ids of ECS Service"
  type        = list(string)
}

variable "propagate_tags" {
  description = "propagate_tags of ECS Service"
  type        = string
  default     = "SERVICE"
  # SERVICE | TASK_DEFINITION | NONE
}

# AWS Load-Balancer

variable "frontend_alb_name" {
  description = "Frontend ALB name"
  type        = string
  default     = null
}

variable "alb_hosts" {
  description = "Frontend ALB routing hostnames"
  type        = list(string)
  default     = []
}

variable "alb_paths" {
  description = "Frontend ALB routing paths"
  type        = list(string)
  default     = []
}

variable "backend_alb_name" {
  description = "The name of AWS ELB"
  type        = string
  default     = null
}

# TargetGroup

variable "target_type" {
  description = "Type of target that you must specify when registering targets with this target group. support instance, ip or alb"
  type        = string
  default     = "ip"
}

variable "health_check_path" {
  description = "Destination for the health check request. Required for HTTP/HTTPS ALB and HTTP NLB. Only applies to HTTP/HTTPS."
  type        = string
  default     = "/health"
}

variable "healthy_threshold" {
  description = "Number of consecutive health checks successes required before considering an unhealthy target healthy."
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Number of consecutive health check failures required before considering the target unhealthy."
  type        = number
  default     = 3
}

variable "stickiness_enabled" {
  description = "Whether stickiness session enabled or not."
  type        = bool
  default     = false
}

variable "stickiness_type" {
  description = "The type of sticky sessions. The only current possible values are lb_cookie, app_cookie for ALBs, and source_ip for NLBs."
  type        = string
  default     = "source_ip"
}

#
variable "listener_port" {
  description = "The listener port number for application service of ELB"
  type        = number
  default     = 8080
}

### CloudMap configuration
variable "namespace_id" {
  description = "CloudMap namespace id for Domain based Service Discovery"
  type        = string
  default     = null
}

variable "namespace_domain_name" {
  description = "CloudMap namespace domain name for Domain based Service Discovery"
  type        = string
  default     = null
}

variable "enable_service_discovery" {
  description = "CloudMap Domain based Service Discovery"
  type        = bool
  default     = true
}

variable "enable_service_connect" {
  description = "CloudMap API only Service Discovery "
  type        = bool
  default     = false
}

variable "service_connect_configuration" {
  type        = any
  default     = null
  description = <<EOF
The ECS Service Connect configuration for this service to discover and connect to services, and be discovered by, and connected from, other services within a namespace

  service_connect_configuration = {
    service = {
      port_name      = "ecs-sample"
      client_alias = {
        port     = 80
      }
    }
  }

EOF
}


# ECR
variable "container_image" {
  description = "container image"
  type        = string
  default     = null
}

variable "image_tag_mutability" {
  description = "image tag mutability"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "image scan on push"
  type        = bool
  default     = false
}

variable "ecr_force_delete_enabled" {
  description = "If true, will delete the repository even if it contains images."
  type        = bool
  default     = true
}

variable "ecr_encryption_type" {
  description = "The encryption type to use for the repository. Valid values are AES256 or KMS."
  type        = string
  default     = null
}

variable "ecr_image_limit" {
  description = "ECR docker image limit count."
  type        = number
  default     = 0
}

variable "ecr_expire_count_type" {
  description = "Valid value is imageCountMoreThan or sinceImagePushed"
  type        = string
  default     = "imageCountMoreThan"
}

variable "ecr_expire_tag_status" {
  description = ""
  type        = string
  default     = "any"
}

variable "ecr_kms_key" {
  description = "The ARN of the KMS key to use when encryption_type is KMS. If not specified, uses the default AWS managed key for ECR."
  type        = string
  default     = null
}

# CodeDeploy
variable "enable_code_deploy" {
  description = "Provision AWS CodeDeploy service"
  type    = bool
  default = true
}

variable "deploy_wait_time" { default = 0 }

variable "task_ephemeral_storage" {
  description = "To allocate an increased amount of ephemeral storage space for a Fargate task"
  type        = number
  default     = 20
}


# ASG Step-Scaling policy
variable "step_scaling_name" {
  description = "ECS StepScaling policy name."
  type        = string
  default     = null
}


variable "max_capacity" {
  description = "The max capacity of the scalable target"
  type        = number
  default     = 4
}


variable "min_capacity" {
  description = "The min capacity of the scalable target"
  type        = number
  default     = 1
}


variable "adjustment_type" {
  type        = string
  description = "Autoscaling policy up adjustment type. Valid value is `ExactCapacity`, `ChangeInCapacity` or `PercentChangeInCapacity`. default is `ChangeInCapacity`"
  default     = "ChangeInCapacity"
}

variable "metric_aggregation_type" {
  description = "Aggregation type for the policy's metrics. Valid value is `Minimum`, `Maximum`, or `Average`. default is `Average`"
  type        = string
  default     = "Average"
}

variable "min_adjustment_magnitude" {
  description = <<EOF
Minimum number to adjust your scalable dimension as a result of a scaling activity.
Only if the adjustment type is `PercentChangeInCapacity`, the scaling policy changes the scalable dimension of the scalable target by this amount.
EOF
  type        = number
  default     = null
}

variable "cooldown" {
  description = "The amount of time, in seconds, after a scaling up completes and before the next scaling up can start"
  type        = number
  default     = 60
}

variable "step_adjustment" {
  type = list(object({
    metric_interval_lower_bound = number
    # Lower bound for the difference between the alarm threshold and the CloudWatch metric.
    metric_interval_upper_bound = number
    # Upper bound for the difference between the alarm threshold and the CloudWatch metric.
    scaling_adjustment          = number
    # Number of members by which to scale, when the adjustment bounds are breached. A positive value scales up. A negative value scales down.
  }))
  description = <<EOF
A set of adjustments that manage scaling up.

step_adjustment = [
  {
    metric_interval_lower_bound = 0.0
    metric_interval_upper_bound = 20.0
    scaling_adjustment          = 0
  },
  {
    metric_interval_lower_bound = 20.0
    metric_interval_upper_bound = 30.0
    scaling_adjustment          = 10.0
  },
  {
    metric_interval_lower_bound = 20.0
    metric_interval_upper_bound = null
    scaling_adjustment          = 30
  },
]

EOF
  default     = []
}


# CloudWatch Alarm
variable "metric_name" {
  description = <<EOF
The name for the alarm's associated metric.

see - https://docs.aws.amazon.com/ko_kr/AmazonECS/latest/developerguide/cloudwatch-metrics.html

CPUUtilization, MemoryUtilization, RequestCount
EOF
  type        = string
  default     = "CPUUtilization"
}

variable "alarm_description" {
  type    = string
  default = null
}

variable "comparison_operator" {
  description = <<EOF
The arithmetic operation to use when comparing the specified Statistic and Threshold. The specified Statistic value is used as the first operand.
Either of the following is supported: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold.
EOF
  type        = string
  default     = "GreaterThanThreshold"
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold."
  type        = number
  default     = 2
}

variable "threshold" {
  description = "The value against which the specified statistic is compared. This parameter is required for alarms based on static thresholds"
  type        = number
  default     = 60.0
}

variable "period" {
  description = "The period in seconds over which the specified statistic is applied."
  type        = number
  default     = 60.0
}

variable "statistic" {
  description = <<EOF
The statistic to apply to the alarm's associated metric.
Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum
EOF
  type        = string
  default     = "Average"
}

# ASG Step-Scaling for Scale-In policy
variable "scaledown_step_scaling_name" {
  description = "ECS StepScaling in policy name."
  type        = string
  default     = null
}


variable "scaledown_max_capacity" {
  description = "The max capacity of the scalable target"
  type        = number
  default     = 4
}


variable "scaledown_min_capacity" {
  description = "The min capacity of the scalable target"
  type        = number
  default     = 1
}


variable "scaledown_adjustment_type" {
  type        = string
  description = "Autoscaling policy up adjustment type. Valid value is `ExactCapacity`, `ChangeInCapacity` or `PercentChangeInCapacity`. default is `ChangeInCapacity`"
  default     = "ChangeInCapacity"
}

variable "scaledown_metric_aggregation_type" {
  description = "Aggregation type for the policy's metrics. Valid value is `Minimum`, `Maximum`, or `Average`. default is `Average`"
  type        = string
  default     = "Average"
}

variable "scaledown_min_adjustment_magnitude" {
  description = <<EOF
Minimum number to adjust your scalable dimension as a result of a scaling activity.
Only if the adjustment type is only `PercentChangeInCapacity`, the scaling policy changes the scalable dimension of the scalable target by this amount.
EOF
  type        = number
  default     = null
}

variable "scaledown_cooldown" {
  description = "The amount of time, in seconds, after a scaling up completes and before the next scaling up can start"
  type        = number
  default     = 60
}

variable "scaledown_step_adjustment" {
  type = list(object({
    metric_interval_lower_bound = number
    # Lower bound for the difference between the alarm threshold and the CloudWatch metric.
    metric_interval_upper_bound = number
    # Upper bound for the difference between the alarm threshold and the CloudWatch metric.
    scaling_adjustment          = number
    # Number of members by which to scale, when the adjustment bounds are breached. A positive value scales up. A negative value scales down.
  }))
  description = <<EOF
A set of adjustments that manage scaling up.

scaledown_step_adjustment = [
  {
    metric_interval_lower_bound = 0.0
    metric_interval_upper_bound = 20.0
    scaling_adjustment          = 0
  },
  {
    metric_interval_lower_bound = 20.0
    metric_interval_upper_bound = 30.0
    scaling_adjustment          = 10.0
  },
  {
    metric_interval_lower_bound = 20.0
    metric_interval_upper_bound = null
    scaling_adjustment          = 30
  },
]

EOF
  default     = []
}


# CloudWatch Alarm
variable "scaledown_metric_name" {
  description = <<EOF
The name for the alarm's associated metric.

see - https://docs.aws.amazon.com/ko_kr/AmazonECS/latest/developerguide/cloudwatch-metrics.html

CPUUtilization, MemoryUtilization, RequestCount
EOF
  type        = string
  default     = "CPUUtilization"
}

variable "scaledown_alarm_description" {
  type    = string
  default = null
}

variable "scaledown_comparison_operator" {
  description = <<EOF
The arithmetic operation to use when comparing the specified Statistic and Threshold. The specified Statistic value is used as the first operand.
Either of the following is supported: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold.
EOF
  type        = string
  default     = "GreaterThanThreshold"
}

variable "scaledown_evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold."
  type        = number
  default     = 2
}

variable "scaledown_threshold" {
  description = "The value against which the specified statistic is compared. This parameter is required for alarms based on static thresholds"
  type        = number
  default     = 60.0
}

variable "scaledown_period" {
  description = "The period in seconds over which the specified statistic is applied."
  type        = number
  default     = 60.0
}

variable "scaledown_statistic" {
  description = <<EOF
The statistic to apply to the alarm's associated metric.
Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum
EOF
  type        = string
  default     = "Average"
}
