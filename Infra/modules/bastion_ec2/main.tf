resource "aws_instance" "dberg_bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.dberg_bastion_sg.id]
  key_name                    = var.key_pair_name

  tags = {
    Name = "${var.name_prefix}-bastion-instance"
  }
}


resource "aws_security_group" "dberg_bastion_sg" {
  name        = "${var.name_prefix}-bastion-sg"
  description = "Allow SSH access to Bastion host"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]  # e.g. "0.0.0.0/0" or your IP like "203.0.113.10/32"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dberg-bastion-sg"
  }
}
