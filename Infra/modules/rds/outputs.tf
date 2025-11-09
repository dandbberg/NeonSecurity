output "rds_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.rds.id
}

output "rds_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.rds.arn
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.rds.endpoint
}

output "rds_address" {
  description = "RDS instance address (hostname)"
  value       = aws_db_instance.rds.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.rds.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.rds.db_name
}

output "rds_username" {
  description = "RDS master username"
  value       = aws_db_instance.rds.username
  sensitive   = true
}

output "rds_master_user_secret_arn" {
  description = "ARN of the master user secret (when manage_master_user_password is true)"
  value       = length(aws_db_instance.rds.master_user_secret) > 0 ? aws_db_instance.rds.master_user_secret[0].secret_arn : null
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds_sg.id
}

output "rds_subnet_group_name" {
  description = "RDS subnet group name"
  value       = aws_db_subnet_group.rds_subnet_group.name
}

