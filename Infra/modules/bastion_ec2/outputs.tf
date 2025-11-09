output "bastion_sg_id" {
  value = aws_security_group.dberg_bastion_sg.id
}

output "bastion_instance_id" {
  value = aws_instance.dberg_bastion.id
}

output "bastion_public_ip" {
  value = aws_instance.dberg_bastion.public_ip
}