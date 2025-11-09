variable "ami_id" {
  description = "AMI ID for the bastion instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for bastion"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID to launch bastion in"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where bastion will be deployed"
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

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}