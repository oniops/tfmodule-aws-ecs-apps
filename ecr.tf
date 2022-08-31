locals {
  ecr_name = var.container_image == null ? format("%s-ecr", local.app_name) : var.container_image
}

resource "aws_ecr_repository" "this" {
  name                 = local.ecr_name
  image_tag_mutability = "MUTABLE"
  force_delete         = var.ecr_force_delete_enabled

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = merge(local.tags, {
    Name = local.ecr_name
  })
}
