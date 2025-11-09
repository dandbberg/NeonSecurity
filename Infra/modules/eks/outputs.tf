output "vpc_id" {
  value = var.vpc_id
}

output "private_subnet_ids" {
  value = var.subnet_ids
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_id" {
  value = var.full_cluster_name  # or however you call your cluster name internally
}

output "cluster_name" {
  value = var.full_cluster_name
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS nodes"
  value       = module.eks.node_security_group_id
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions (if enabled)"
  value       = var.enable_github_actions ? aws_iam_role.github_actions[0].arn : null
}

output "github_actions_role_name" {
  description = "Name of the IAM role for GitHub Actions (if enabled)"
  value       = var.enable_github_actions ? aws_iam_role.github_actions[0].name : null
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "NeonSecurityTask_irsa_role_arn" {
  description = "IAM role ARN used by NeonSecurityTask ServiceAccount (if enabled)"
  value       = var.enable_NeonSecurityTask_irsa ? aws_iam_role.NeonSecurityTask_irsa[0].arn : null
}