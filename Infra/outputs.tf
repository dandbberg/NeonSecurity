output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "rds_endpoint" {
  description = "RDS instance endpoint (if RDS is enabled)"
  value       = var.enable_rds ? module.rds[0].rds_endpoint : null
}

output "rds_address" {
  description = "RDS instance address (if RDS is enabled)"
  value       = var.enable_rds ? module.rds[0].rds_address : null
}

output "rds_port" {
  description = "RDS instance port (if RDS is enabled)"
  value       = var.enable_rds ? module.rds[0].rds_port : null
}

output "rds_database_name" {
  description = "RDS database name (if RDS is enabled)"
  value       = var.enable_rds ? module.rds[0].rds_database_name : null
}

output "rds_master_user_secret_arn" {
  description = "ARN of the RDS master user secret in Secrets Manager (if RDS is enabled and manage_master_user_password is true)"
  value       = var.enable_rds && var.rds_manage_master_user_password ? module.rds[0].rds_master_user_secret_arn : null
}

output "kms_key_arn" {
  description = "KMS key ARN used for encrypting secrets (if RDS is enabled)"
  value       = var.enable_rds ? module.kms[0].kms_key_arn : null
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions (if enabled)"
  value       = module.eks.github_actions_role_arn
}

output "github_actions_role_name" {
  description = "Name of the IAM role for GitHub Actions (if enabled)"
  value       = module.eks.github_actions_role_name
}

output "ecr_repository_urls" {
  description = "Map of ECR repository names to URLs (if ECR is enabled)"
  value       = var.enable_ecr ? module.ecr[0].repository_urls : null
}

output "ecr_repository_names" {
  description = "List of ECR repository names (if ECR is enabled)"
  value       = var.enable_ecr ? module.ecr[0].repository_names : null
}

output "NeonSecurityTask_irsa_role_arn" {
  description = "IAM role ARN for NeonSecurityTask ServiceAccount (if enabled)"
  value       = var.enable_NeonSecurityTask_irsa ? module.eks.NeonSecurityTask_irsa_role_arn : null
}