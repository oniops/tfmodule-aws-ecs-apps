module "StepScale" {
  source                   = "./modules/step-scaling"
  count                    = var.step_scaling_name != null && length(var.step_adjustment) > 0 ? 1 : 0
  #
  cluster_name             = var.cluster_name
  service_name             = local.service_name
  app_name                 = var.app_name
  step_scaling_name        = var.step_scaling_name
  max_capacity             = var.max_capacity
  min_capacity             = var.min_capacity
  adjustment_type          = var.adjustment_type
  metric_aggregation_type  = var.metric_aggregation_type
  min_adjustment_magnitude = var.min_adjustment_magnitude
  step_adjustment          = var.step_adjustment
  metric_name              = var.metric_name
  evaluation_periods       = var.evaluation_periods
  period                   = var.period
  threshold                = var.threshold
  statistic                = var.statistic
}

module "StepScaleIn" {
  source                   = "./modules/step-scaling"
  count                    = var.scaledown_step_scaling_name != null && length(var.scaledown_step_adjustment) > 0 ? 1 : 0
  #
  cluster_name             = var.cluster_name
  service_name             = local.service_name
  app_name                 = var.app_name
  step_scaling_name        = var.scaledown_step_scaling_name
  max_capacity             = var.scaledown_max_capacity
  min_capacity             = var.scaledown_min_capacity
  adjustment_type          = var.scaledown_adjustment_type
  metric_aggregation_type  = var.scaledown_metric_aggregation_type
  min_adjustment_magnitude = var.scaledown_min_adjustment_magnitude
  step_adjustment          = var.scaledown_step_adjustment
  metric_name              = var.scaledown_metric_name
  evaluation_periods       = var.scaledown_evaluation_periods
  period                   = var.scaledown_period
  threshold                = var.scaledown_threshold
  statistic                = var.scaledown_statistic
}
