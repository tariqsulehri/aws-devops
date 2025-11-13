##############################################
# OUTPUTS for ALB Module
##############################################

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.backend_node_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB to access from internet"
  value       = aws_lb.backend_node_alb.dns_name
}

output "alb_target_group_arn" {
  description = "Target Group ARN associated with this ALB"
  value       = aws_lb_target_group.backend_node_tg.arn
}
