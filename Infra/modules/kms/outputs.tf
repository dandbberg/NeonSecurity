output "kms_key_id" {
  description = "KMS key ID"
  value       = aws_kms_key.secrets.id
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.secrets.arn
}

output "kms_alias_arn" {
  description = "KMS alias ARN"
  value       = aws_kms_alias.secrets.arn
}

output "kms_alias_name" {
  description = "KMS alias name"
  value       = aws_kms_alias.secrets.name
}

