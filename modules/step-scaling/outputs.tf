output "asg_target_id" {
  value = aws_appautoscaling_target.this.id
}

output "asg_policy_name" {
  value = local.asg_policy_name
}

output "asg_policy_type" {
  value = aws_appautoscaling_policy.this.policy_type
}

output "asg_policy_arn" {
  value = aws_appautoscaling_policy.this.arn
}

output "resource_id" {
  value = local.ecs_resource_id
}

output "alarm_name" {
  value = local.alarm_name
}

output "alarm_arn" {
  value = aws_cloudwatch_metric_alarm.this.arn
}


