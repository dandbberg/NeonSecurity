module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.1"

  cluster_name = var.full_cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                     = true

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    node_group = {
      desired_size   = var.desired_size
      max_size       = var.max_size
      min_size       = var.min_size
      instance_type  = var.eks_instance_type
      subnet_ids     = var.subnet_ids

      tags = {
        Name = "${var.node_name}"
      }
    }
  }

  tags = {
    Environment = var.name_prefix
    Terraform   = "true"
  }
}

resource "aws_security_group_rule" "allow_bastion_to_eks_api" {
  type                     = "ingress"
  from_port                = var.bastion_sg_eks_rule_port
  to_port                  = var.bastion_sg_eks_rule_port
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = var.bastion_sg_id
  description              = "Allow bastion access to EKS API"
}

module "eks_aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = true

  aws_auth_users = [
    {
      userarn  = var.map_user_userarn
      username = var.map_user_username
      groups   = var.map_user_groups
    }
  ]

  aws_auth_roles = var.enable_github_actions ? [
    {
      rolearn  = aws_iam_role.github_actions[0].arn
      username = "github-actions"
      groups   = var.github_actions_kubernetes_groups
    }
  ] : []

  depends_on = [module.eks]
}