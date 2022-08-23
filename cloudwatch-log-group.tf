resource "aws_cloudwatch_log_group" "this" {
  count             = var.enable_cloudwatch_log_group && var.cloudwatch_log_group_name == null ? 1 : 0
  name              = local.cloudwatch_log_group_name
  retention_in_days = var.retention_in_days
  lifecycle {
    create_before_destroy = true
  }
}

output "cloudwatch_log_group_name" {
  value = try(aws_cloudwatch_log_group.this.*.name, "")
}
