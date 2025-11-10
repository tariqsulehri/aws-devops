##############################################
# Security Groups - outputs.tf
# Purpose: expose SG ids to calling module(s)
##############################################

output "admin_sg_id" {
  description = "Security Group ID for admin (SSH)"
  value       = aws_security_group.admin_sg.id
}

output "web_sg_id" {
  description = "Security Group ID for web (frontend)"
  value       = aws_security_group.web_sg.id
}

output "alb_sg_id" {
  description = "Security Group ID for ALB (public)"
  value       = aws_security_group.alb_sg.id
}

output "backend_sg_id" {
  description = "Security Group ID for backend application servers"
  value       = aws_security_group.backend_sg.id
}

output "db_sg_id" {
  description = "Security Group ID for DB / RDS"
  value       = aws_security_group.db_sg.id
}
