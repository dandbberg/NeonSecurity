variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Enable automatic key rotation"
  type        = bool
  default     = true
}

variable "kms_key_policy" {
  description = "Custom KMS key policy (optional). If not provided, a default policy will be used."
  type        = string
  default     = null
}

