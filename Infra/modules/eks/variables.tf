variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "full_cluster_name" {
  description = "Full EKS cluster name including prefix"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.23" # or whatever you want
}

variable "vpc_id" {
  description = "VPC ID to deploy EKS in"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for worker nodes"
  type        = list(string)
}

variable "map_user_userarn" {
  description = "IAM user ARN for aws-auth configmap"
  type        = string
}

variable "map_user_username" {
  description = "User name for aws-auth configmap"
  type        = string
}

variable "map_user_groups" {
  description = "Groups for aws-auth configmap"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired size of node group"
  type        = number
}

variable "max_size" {
  description = "Max size of node group"
  type        = number
}

variable "min_size" {
  description = "Min size of node group"
  type        = number
}

variable "eks_instance_type" {
  description = "EKS worker node instance type"
  type        = string
  default     = "t3.medium"
}

variable "node_name" {
  description = "Name tag for nodes"
  type        = string
}

variable "bastion_sg_eks_rule_port" {
  description = "Port for bastion security group to access EKS API"
  type        = number
  default     = 443
}

variable "bastion_sg_id" {
  description = "Security group ID of the bastion host"
  type        = string
}

# Task3 IRSA / Secrets
variable "enable_NeonSecurityTask_irsa" {
  description = "Create IAM role for NeonSecurityTask ServiceAccount (IRSA)"
  type        = bool
  default     = false
}

variable "NeonSecurityTask_irsa_service_account_name" {
  description = "ServiceAccount name for NeonSecurityTask pod"
  type        = string
  default     = "NeonSecurityTask-NeonSecurityTask-chart"
}

variable "NeonSecurityTask_irsa_service_account_namespace" {
  description = "Namespace of the NeonSecurityTask ServiceAccount"
  type        = string
  default     = "default"
}

variable "NeonSecurityTask_irsa_secretsmanager_arn" {
  description = "Secrets Manager ARN the NeonSecurityTask IRSA role should read (optional)"
  type        = string
  default     = ""
}

variable "NeonSecurityTask_irsa_kms_key_arn" {
  description = "KMS Key or alias ARN required to decrypt the Secrets Manager secret (optional)"
  type        = string
  default     = ""
}

# GitHub Actions IAM Role
variable "enable_github_actions" {
  description = "Enable IAM role for GitHub Actions"
  type        = bool
  default     = false
}

variable "github_repository_subjects" {
  description = "List of GitHub repository subjects that can assume the role (e.g., ['repo:owner/repo:ref:refs/heads/main', 'repo:owner/repo:environment:production'])"
  type        = list(string)
  default     = []
}

variable "github_actions_kubernetes_groups" {
  description = "Kubernetes groups to assign to GitHub Actions role"
  type        = list(string)
  default     = ["system:masters"]
}