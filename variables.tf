### ECS Cluster
variable "delete_service" {
  description = "Delete ecs service and related with"
  type        = bool
  default     = false
}

variable "delete_task_definition" {
  description = "Delete ecs task-definition"
  type        = bool
  default     = false
}

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

# CloudMap
variable "cloud_map_namespace_id" {
  description = "CloudMap namespace id for Service Discovery"
  type        = string
}

variable "cloud_map_namespace_name" {
  description = "CloudMap namespace name for Service Discovery"
  type        = string
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

# CodeDeploy
variable "deploy_wait_time" { default = 0 }
