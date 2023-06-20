output "ecs_cluster_id" {
  description = "ID of the ECS Cluster"
  value       = data.aws_ecs_cluster.this.id
}

output "ecs_cluster_name" {
  description = "The name of the ECS Cluster"
  value       = var.cluster_name
}

output "ecs_task_definition_id" {
  description = "ID of the ECS Task Definition"
  value       = concat(aws_ecs_task_definition.this.*.id, [""])[0]
}

output "ecs_task_definition_family" {
  description = "ID of the ECS Task Definition"
  value       = concat(aws_ecs_task_definition.this.*.family, [""])[0]
}

output "ecs_task_definition_revision" {
  description = "ID of the ECS Task Definition"
  value       = concat(aws_ecs_task_definition.this.*.revision, [""])[0]
}

output "ecs_service_id" {
  description = "ID of the ECS Application Service"
  value       = concat(aws_ecs_service.this.*.id, [""])[0]
}

output "ecs_service_name" {
  description = "The name of the ECS Application Service"
  value       = local.service_name
}

output "ecs_container_name" {
  description = "The name of the ECS Application Container"
  value       = local.container_name
}

output "ecr_name" {
  value = aws_ecr_repository.this.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.this.repository_url
}

output "target_group_arn" {
  value = try(aws_lb_target_group.blue[0].arn, "")
}

output "backend_alb_listener_arn" {
  value = local.backend_alb_listener_arn
}

output "frontend_alb_listener_arn" {
  value = local.frontend_alb_listener_arn
}

output "cloudwatch_log_group_name" {
  value = try(aws_cloudwatch_log_group.this.*.name, "")
}

output "namespace_domain_name" {
  description = "cloud_map_namespace_name"
  value       = var.enable_service_discovery ? try(data.aws_service_discovery_dns_namespace.dns[0].name, null) : ""
}

output "code_deploy_name" {
  description = "CodeDeploy name"
  value       = local.code_deploy_name
}

output "code_deploy_grp_name" {
  description = "CodeDeploy Group name"
  value       = local.code_deploy_grp_name
}
