locals {
  enable_ecr_repository  = var.repository == null ? true : false
  ecr_name               = var.container_image == null ? format("%s-ecr", local.app_name) : var.container_image
  enabled_ecr_encryption = var.ecr_encryption_type != null && var.ecr_kms_key != null ? true : false
}

resource "aws_ecr_repository" "this" {
  count                = local.enable_ecr_repository ? 1 : 0
  name                 = local.ecr_name
  image_tag_mutability = "MUTABLE"
  force_delete         = var.ecr_force_delete_enabled

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  dynamic "encryption_configuration" {
    for_each = local.enabled_ecr_encryption ? ["true"] : []
    content {
      encryption_type = var.ecr_encryption_type
      kms_key         = var.ecr_kms_key
    }
  }

  tags = merge(local.tags, {
    Name = local.ecr_name
  })
}

resource "aws_ecr_lifecycle_policy" "this" {
  count      = local.enable_ecr_repository && var.ecr_image_limit > 0 ? 1 : 0
  repository = try(aws_ecr_repository.this[0].name, null)
  policy     = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = format("keep last %s images", var.ecr_image_limit)
        action       = {
          type = "expire"
        }
        selection = {
          tagStatus   = var.ecr_expire_tag_status
          countType   = var.ecr_expire_count_type
          countNumber = var.ecr_image_limit
        }
      }
    ]
  })
}
