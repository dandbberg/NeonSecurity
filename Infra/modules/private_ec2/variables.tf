variable "vpc_id" {
  description = "VPC ID where instance will be deployed"
  type        = string
}

variable "private_subnet_id" {
  description = "Subnet ID for the private EC2 instance"
  type        = string
}

variable "bastion_sg_id" {
  description = "Security Group ID of bastion to allow SSH from"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the private instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for private instance"
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