resource "aws_ecr_repository" "repositories" {
  for_each = toset(var.repository_names)

  name                 = each.value
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  dynamic "encryption_configuration" {
    for_each = var.encryption_type != null ? [1] : []
    content {
      encryption_type = var.encryption_type
      kms_key         = var.kms_key_id
    }
  }

  tags = merge(
    {
      Name        = each.value
      Environment = var.name_prefix
      Terraform   = "true"
    },
    var.tags
  )
}

