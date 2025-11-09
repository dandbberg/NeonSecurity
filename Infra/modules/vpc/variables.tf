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

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into bastion"
  type        = string
  default     = "87.68.226.66/32"  # change to your IP for security
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}