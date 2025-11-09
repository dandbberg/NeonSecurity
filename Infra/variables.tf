#VPC
variable "aws_region" {
  description = "AWS region to deploy in"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for all VPC resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for the bastion instance"
  type        = string
}

#BASTION
variable "instance_type" {
  description = "Instance type for bastion"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into bastion"
  type        = string
}

variable "key_pair_name" {
  description = "SSH key pair name"
  type        = string
}


#EKS
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the cluster"
  type        = string
  default     = "1.33"
}

variable "map_user_userarn" {
  description = "IAM user ARN for aws-auth configmap"
  type        = string
}

variable "map_user_username" {
  description = "Username mapped in aws-auth"
  type        = string
}

variable "map_user_groups" {
  description = "Groups assigned in aws-auth"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired node group size"
  type        = number
}

variable "max_size" {
  description = "Max node group size"
  type        = number
}

variable "min_size" {
  description = "Min node group size"
  type        = number
}

variable "eks_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_name" {
  description = "Name tag for node group"
  type        = string
}

variable "bastion_sg_eks_rule_port" {
  description = "Port for bastion access to EKS API"
  type        = number
  default     = 443
}

# GitHub Actions IAM Role
variable "enable_github_actions" {
  description = "Enable IAM role for GitHub Actions to access EKS"
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

#RDS
variable "enable_rds" {
  description = "Enable RDS database deployment"
  type        = bool
  default     = false
}

variable "rds_db_identifier" {
  description = "Identifier for the RDS instance"
  type        = string
  default     = "db"
}

variable "rds_engine" {
  description = "Database engine (postgres, mysql, mariadb, etc.)"
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.4"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling in GB"
  type        = number
  default     = 100
}

variable "rds_db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "mydb"
}

variable "rds_db_username" {
  description = "Master username for the database"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "rds_manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager (recommended, no password in git)"
  type        = bool
  default     = true
}

variable "rds_db_password" {
  description = "Master password for the database (only used if rds_manage_master_user_password is false - NOT RECOMMENDED)"
  type        = string
  sensitive   = true
  default     = null
}

variable "rds_db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "rds_backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot when deleting"
  type        = bool
  default     = false
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

#KMS
variable "kms_deletion_window_in_days" {
  description = "Duration in days after which the KMS key is deleted after destruction"
  type        = number
  default     = 30
}

variable "kms_enable_key_rotation" {
  description = "Enable automatic KMS key rotation"
  type        = bool
  default     = true
}

#ECR
variable "enable_ecr" {
  description = "Enable ECR repositories"
  type        = bool
  default     = true
}

variable "ecr_repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default     = ["dberg-ecr1", "dberg-ecr2", "neonsecurity-ecr"]
}

variable "ecr_image_tag_mutability" {
  description = "Image tag mutability setting (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "ecr_encryption_type" {
  description = "Encryption type for ECR repositories (AES256 or KMS)"
  type        = string
  default     = "AES256"
}

variable "ecr_kms_key_id" {
  description = "KMS key ID for ECR encryption (optional)"
  type        = string
  default     = null
}

# Task3 IRSA / Secrets Manager
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
  description = "Secrets Manager ARN the NeonSecurityTask IRSA role should read"
  type        = string
  default     = ""
}

variable "NeonSecurityTask_irsa_kms_key_arn" {
  description = "KMS key or alias ARN used to encrypt the Secrets Manager secret"
  type        = string
  default     = ""
}