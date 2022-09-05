locals {
  ecr_name               = var.container_image == null ? format("%s-ecr", local.app_name) : var.container_image
  enabled_ecr_encryption = var.ecr_encryption_type != null && var.ecr_kms_key != null ? true : false
}

resource "aws_ecr_repository" "this" {
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
