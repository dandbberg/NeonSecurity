locals {
  NeonSecurityTask_irsa_enabled = var.enable_NeonSecurityTask_irsa ? 1 : 0
}

resource "aws_iam_role" "NeonSecurityTask_irsa" {
  count = local.NeonSecurityTask_irsa_enabled

  name = "${var.name_prefix}-NeonSecurityTask-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:${var.NeonSecurityTask_irsa_service_account_namespace}:${var.NeonSecurityTask_irsa_service_account_name}"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.name_prefix}-NeonSecurityTask-irsa"
    Environment = var.name_prefix
    Terraform   = "true"
  }
}

resource "aws_iam_role_policy" "NeonSecurityTask_irsa_secretsmanager" {
  count = local.NeonSecurityTask_irsa_enabled * (var.NeonSecurityTask_irsa_secretsmanager_arn != "" ? 1 : 0)

  name = "${var.name_prefix}-NeonSecurityTask-secrets"
  role = aws_iam_role.NeonSecurityTask_irsa[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Sid    = "SecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.NeonSecurityTask_irsa_secretsmanager_arn
      }
    ], var.NeonSecurityTask_irsa_kms_key_arn != "" ? [
      {
        Sid    = "KMSAccessForSecrets"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = var.NeonSecurityTask_irsa_kms_key_arn
      }
    ] : [])
  })
}

