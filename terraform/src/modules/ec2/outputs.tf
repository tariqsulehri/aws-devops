##############################################
# EC2 OUTPUTS
##############################################
# Uncomment if using Elastic IP
# output "node_app_public_ip" {
#   description = "Public IP of Node.js server"
#   value       = aws_eip.node_app_eip.public_ip
# }

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2_instance.id
}

output "ec2_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.ec2_instance.private_ip
}
output "ec2_public_ip" {
  description = "Elastic IP if allocated, else the instance public IP (if any)"
  value = (
    length(aws_eip.public_eip) > 0 ?
    aws_eip.public_eip[0].public_ip :
    aws_instance.ec2_instance.public_ip
  )
}