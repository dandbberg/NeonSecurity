module "vpc" {
  source      = "./modules/vpc"
  name_prefix = var.name_prefix
  vpc_cidr    = var.vpc_cidr
  azs         = var.azs
}

module "bastion" {
  depends_on = [ module.vpc ]
  source          = "./modules/bastion_ec2"
  ami_id          = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = module.vpc.public_subnets[0]
  vpc_id          = module.vpc.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
  key_pair_name   = var.key_pair_name
  name_prefix      = var.name_prefix
}

# module "private_ec2" {
#   source           = "./modules/private_ec2"
#   vpc_id           = module.vpc.vpc_id
#   private_subnet_id = module.vpc.private_subnets[0]
#   bastion_sg_id    = module.bastion.bastion_sg_id
#   ami_id           = var.ami_id
#   instance_type    = var.instance_type
#   key_pair_name    = var.key_pair_name
#   name_prefix      = var.name_prefix
# }

module "eks" {
  source = "./modules/eks"

  name_prefix       = var.name_prefix
  full_cluster_name = "${var.name_prefix}-${var.cluster_name}"
  cluster_version   = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  map_user_userarn  = var.map_user_userarn
  map_user_username = var.map_user_username
  map_user_groups   = var.map_user_groups

  desired_size      = var.desired_size
  max_size          = var.max_size
  min_size          = var.min_size
  eks_instance_type = var.eks_instance_type
  node_name         = var.node_name

  bastion_sg_eks_rule_port = var.bastion_sg_eks_rule_port
  bastion_sg_id            = module.bastion.bastion_sg_id

  # GitHub Actions IAM Role
  enable_github_actions            = var.enable_github_actions
  github_repository_subjects       = var.github_repository_subjects
  github_actions_kubernetes_groups = var.github_actions_kubernetes_groups

  # NeonSecurityTask IRSA
  enable_NeonSecurityTask_irsa                    = var.enable_NeonSecurityTask_irsa
  NeonSecurityTask_irsa_service_account_name      = var.NeonSecurityTask_irsa_service_account_name
  NeonSecurityTask_irsa_service_account_namespace = var.NeonSecurityTask_irsa_service_account_namespace
  NeonSecurityTask_irsa_secretsmanager_arn        = var.NeonSecurityTask_irsa_secretsmanager_arn
  NeonSecurityTask_irsa_kms_key_arn               = var.NeonSecurityTask_irsa_kms_key_arn
}

module "kms" {
  count  = var.enable_rds ? 1 : 0
  source = "./modules/kms"

  name_prefix            = var.name_prefix
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation    = var.kms_enable_key_rotation
}

# ECR Repositories for Docker images
module "ecr" {
  count  = var.enable_ecr ? 1 : 0
  source = "./modules/ecr"

  name_prefix      = var.name_prefix
  repository_names = var.ecr_repository_names

  image_tag_mutability            = var.ecr_image_tag_mutability
  scan_on_push                    = var.ecr_scan_on_push
  encryption_type                 = var.ecr_encryption_type
  kms_key_id                      = var.ecr_kms_key_id
}

module "rds" {
  count  = var.enable_rds ? 1 : 0
  source = "./modules/rds"

  depends_on = [module.eks, module.kms]

  name_prefix = var.name_prefix
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets

  db_identifier            = var.rds_db_identifier
  engine                   = var.rds_engine
  engine_version           = var.rds_engine_version
  instance_class           = var.rds_instance_class
  allocated_storage        = var.rds_allocated_storage
  max_allocated_storage    = var.rds_max_allocated_storage
  db_name                  = var.rds_db_name
  db_username              = var.rds_db_username
  manage_master_user_password = var.rds_manage_master_user_password
  master_user_secret_kms_key_id = var.rds_manage_master_user_password ? module.kms[0].kms_key_id : null
  db_password              = var.rds_manage_master_user_password ? null : var.rds_db_password
  db_port                  = var.rds_db_port
  backup_retention_period  = var.rds_backup_retention_period
  skip_final_snapshot      = var.rds_skip_final_snapshot
  deletion_protection      = var.rds_deletion_protection

  allowed_security_group_ids = [module.eks.node_security_group_id]
  bastion_security_group_ids = [module.bastion.bastion_sg_id]
}


terraform {
 backend "s3" {
   bucket         = "919649607464-tfstate-bucket"      # Replace with your S3 bucket name
   key            = "infra/infra.tfstate"       # Path within the bucket
   region         = "eu-west-1"                         # Your AWS region
   encrypt        = true                                # (Optional) Encrypt state file at rest
   profile        = "default"                            # (Optional) AWS CLI profile to use
   #use_lockfile   = true
 }
}