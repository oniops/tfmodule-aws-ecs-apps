# tfmodule-aws-ecs-apps

AWS ECS 애플리케이션 서비스를 프로비저닝 하는 테라폼 모듈 입니다.

## Usage

```
module "myapp" {
  source  = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-ecs-apps.git"

  context = {
    project     = "demo"
    region      = "ap-northeast-2"
    environment = "Development"
    owner       = "owner@your-company.com"
    domain      = "your-public-domain.com"
    pri_domain  = "your-private-domain.local"
    tags        = {
        Environment = "Development"
    }
    name_prefix = "demo-dev"
  }
  
  cluster_name       = "<my-ecs-cluster-name>"
  execution_role_arn = "<AmazonEcsTaskExecutionRoleARN>"
  app_name           = "myapp"
  task_cpu           = 256
  task_memory        = 512
  task_port          = 8080
  desired_count      = 1
  environments       = []
  retention_in_days  = 90
  task_role_arn      = "<TaskRoleARN>"
  #
  vpc_id             = "<vpc-id>"
  subnets            = [ "<subnet-id>" ]
  backend_alb_name   = "<your-backend-alb-name>"
  security_group_ids = [ "<security-group-id>" ]
  #
  cloud_map_namespace_id   = "<cloud-map-namespace-id>"
  cloud_map_namespace_name = "<cloud-map-namespace-name>"
  # ECR
  
}
```
 
## Input Variables
 

## Output Values
