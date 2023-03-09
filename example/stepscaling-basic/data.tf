data "aws_caller_identity" "current" {}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.project}EcsTaskExecutionRole"
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${local.name_prefix}-vpc"]
  }
}

# ECS App 서비스는 app 서브넷에 배포
data "aws_subnets" "app" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:Name"
    values = ["${local.name_prefix}-app-*"]
  }
}

# TaskExecutionRole for ECS Application service
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
