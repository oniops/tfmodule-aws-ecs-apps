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
  app_name           = "simple"
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
  name = local.sg_name
  tags = merge(local.tags, { Name = local.sg_name })
}

module "simple" {
  # source  = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-ecs-apps.git"
  source  = "../../"
  context = module.ctx.context

  cluster_name             = format("%s-ecs", local.name_prefix)
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  app_name                 = local.app_name
  task_cpu                 = 256
  task_memory              = 512
  task_port                = 8080
  listener_port            = 8083
  desired_count            = 1
  environments             = []
  retention_in_days        = 90
  task_role_arn            = aws_iam_role.task_role.arn
  # VPC
  vpc_id                   = data.aws_vpc.this.id
  subnets                  = data.aws_subnets.app.ids
  backend_alb_name         = format("%s-backend-alb", local.name_prefix)
  security_group_ids       = [aws_security_group.this.id]
  enable_service_discovery = false
  # ECR
  ecr_image_limit          = 30

  depends_on = [aws_iam_role.task_role]
}
