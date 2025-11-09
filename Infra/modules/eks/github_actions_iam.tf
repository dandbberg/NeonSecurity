# OIDC Provider for GitHub Actions
data "tls_certificate" "github" {
  count = var.enable_github_actions ? 1 : 0
  url   = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.enable_github_actions ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = var.enable_github_actions ? [data.tls_certificate.github[0].certificates[0].sha1_fingerprint] : []

  tags = {
    Name        = "${var.name_prefix}-github-oidc"
    Environment = var.name_prefix
    Terraform   = "true"
  }
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  count = var.enable_github_actions ? 1 : 0

  name = "${var.name_prefix}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github[0].arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = var.github_repository_subjects
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.name_prefix}-github-actions-role"
    Environment = var.name_prefix
    Terraform   = "true"
  }

  depends_on = [aws_iam_openid_connect_provider.github]
}

# Policy for EKS access
resource "aws_iam_role_policy" "github_actions_eks" {
  count = var.enable_github_actions ? 1 : 0

  name = "${var.name_prefix}-github-actions-eks-policy"
  role = aws_iam_role.github_actions[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi"
        ]
        Resource = module.eks.cluster_arn
      }
    ]
  })

  depends_on = [
    module.eks,
    aws_iam_role.github_actions
  ]
}

# Policy for ECR access (for pushing/pulling Docker images)
resource "aws_iam_role_policy" "github_actions_ecr" {
  count = var.enable_github_actions ? 1 : 0

  name = "${var.name_prefix}-github-actions-ecr-policy"
  role = aws_iam_role.github_actions[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      }
    ]
  })
}

# Note: GitHub Actions role is mapped to Kubernetes via the aws-auth module's aws_auth_roles
# See main.tf for the integration

