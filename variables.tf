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
variable "fullname" {
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

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#runtime-platform
variable "operating_system_family" {
  description = <<EOF
OS runtime platform
The valid values are LINUX, WINDOWS_SERVER_2019_FULL, WINDOWS_SERVER_2019_CORE, WINDOWS_SERVER_2022_FULL, and WINDOWS_SERVER_2022_CORE.
EOF
  type        = string
  default     = "LINUX"
}

variable "cpu_architecture" {
  description = "The valid values are X86_64 and ARM64."
  type        = string
  default     = "X86_64"
}

variable "capacity_provider_strategy" {
  description = <<EOF
Capacity provider strategies to use for the service. Can be one or more

  capacity_provider_strategy = {
    one = {
      capacity_provider = "FARGATE"
      weight = 0
      base = 1
    }
    two = {
      capacity_provider = "FARGATE_SPOT"
      weight = 0
      base = 100
    }
  }

EOF

  type    = any
  default = {}
}

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

variable "readonlyRootFilesystem" {
  description = "readonlyRootFilesystem"
  type        = bool
  default     = null
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
  description = "launch_type of ECS Service. values are EC2, FARGATE, EXTERNAL"
  type        = string
  default     = null
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
  description = "health_check_grace_period_seconds of ECS Service. It is only used when bind to load-balancer"
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
  default     = "ECS"
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

variable "source_ip" {
  description = "Contains a single values item which is a list of source IP CIDR notations to match. Wildcards are not supported"
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

variable "health_check_protocol" {
  description = "Destination for the health check protol. Required for HTTP / TCP"
  type        = string
  default     = null
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
variable "repository" {
  description = "container image repository"
  type        = object({
    url  = string
    name = string
  })
  default = null
}

variable "repository_url" {
  description = "container image repository url"
  type        = string
  default     = null
}

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
  type        = bool
  default     = true
}

variable "deploy_wait_time" { default = 0 }

variable "task_ephemeral_storage" {
  description = "To allocate an increased amount of ephemeral storage space for a Fargate task"
  type        = number
  default     = 20
}
