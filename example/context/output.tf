output "context" {
  value = {
    # aws_profile  = var.context.aws_profile
    project      = var.context.project
    region       = var.context.region
    region_alias = local.region_alias
    environment  = var.context.environment
    env_alias    = local.env_alias
    env_code     = local.env_code
    department   = var.context.department
    owner        = var.context.owner
    team         = var.team
    cost_center  = var.cost_center
    domain       = var.context.domain
    pri_domain   = var.context.pri_domain
    name_prefix  = local.name_prefix
    tags         = local.tags
  }
}

output "context_string" {
  value = join(",", [for key, value in var.context : "${key}=${value}"])
}

output "name_prefix" {
  value = local.name_prefix
}

output "tags" {
  value = local.tags
}

output "tags_string" {
  value = join(",", [for key, value in local.tags : "${key}=${value}"])
}

output "region" {
  value = var.context.region
}

output "region_alias" {
  value = local.region_alias
}

output "project" {
  value = var.context.project
}

output "environment" {
  value = var.context.environment
}

output "env_alias" {
  value = local.env_alias
}

output "env_code" {
  value = local.env_code
}

output "owner" {
  value = var.context.owner
}

output "team" {
  value = var.team
}

output "cost_center" {
  value = var.cost_center
}

output "domain" {
  value = var.context.domain
}

output "pri_domain" {
  value = var.context.pri_domain
}
