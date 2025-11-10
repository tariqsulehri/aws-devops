output "rds_endpoint" {
  description = "RDS endpoint to connect from backend"
  value       = aws_db_instance.rds.address
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.rds.port
}
