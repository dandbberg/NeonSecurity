variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for ECR repositories (AES256 or KMS). Set to null to use default encryption."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (required if encryption_type is KMS)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to apply to repositories"
  type        = map(string)
  default     = {}
}

