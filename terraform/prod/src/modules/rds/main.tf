# ----------------------------------------------------
# RDS MODULE - MAIN FILE
# Creates a MySQL RDS instance in private subnet(s)
# ----------------------------------------------------



resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-${var.env}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-rds-subnet-group" }
  )
}

resource "aws_db_instance" "rds" {
  identifier             = "${var.project_name}-${var.env}-mysql-db"
  engine                 = "mysql"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  max_allocated_storage  = var.max_allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = var.security_group_ids

  db_name                 = var.db_name
  username                = var.username
  password                = var.password
  port                    = var.port
  publicly_accessible     = false
  skip_final_snapshot     = true
  deletion_protection     = false
  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-${var.env}-mysql-db" }
  )
}
