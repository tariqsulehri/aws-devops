##############################################
# Security Groups - main.tf
# Creates Admin, Web, ALB, Backend, and DB security groups.
# - ALB is public-facing.
# - Web SG can be used for frontend instances (public).
# - Backend SG allows traffic only from ALB (and optionally web/admin).
# - DB SG allows MySQL from Backend SG only.
##############################################

locals {
  name_prefix = "${var.project_name}-${var.env}"
  common_tags = merge(var.tags, {
    Project     = var.project_name,
    Environment = var.env,
  })
}

# -----------------------------
# 1) Admin SG - allow SSH from admin_ip only
# -----------------------------
resource "aws_security_group" "admin_sg" {
  name        = "${local.name_prefix}-admin-sg"
  description = "SSH access for administrators (restricted by IP)"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-admin-sg", Layer = "admin" })
}

# -----------------------------
# 2) Web SG - public access for frontend (HTTP/HTTPS)
# -----------------------------
resource "aws_security_group" "web_sg" {
  name        = "${local.name_prefix}-web-sg"
  description = "Public access for frontend (HTTP/HTTPS)"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow admin to SSH to frontend if needed (optional)
  ingress {
    description     = "SSH from Admin SG (optional)"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.admin_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-web-sg", Layer = "web" })
}

# -----------------------------
# 3) ALB SG - public ingress (HTTP/HTTPS), generic outbound
#    (keep ALB egress broad to avoid circular dependency)
# -----------------------------
resource "aws_security_group" "alb_sg" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for Application Load Balancer (public)"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ALB can talk outbound to backend instances on app_port.
  # To avoid circular references and keep ALB flexible, allow outbound to all.
  egress {
    description = "Allow all outbound (ALB - targets)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-alb-sg", Layer = "alb" })
}

# -----------------------------
# 4) Backend SG - allow only app_port from ALB and optionally from web/admin
# -----------------------------
resource "aws_security_group" "backend_sg" {
  name        = "${local.name_prefix}-backend-sg"
  description = "Backend application servers (allow traffic from ALB on app_port)"
  vpc_id      = var.vpc_id

  # Allow app traffic from ALB SG
  ingress {
    description     = "App traffic from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Optionally allow traffic from web_sg (if direct web->backend required)
  ingress {
    description     = "Allow HTTP from frontend web SG (if used)"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  # Allow SSH from admin SG for troubleshooting (optional)
  ingress {
    description     = "SSH from admin SG (for maintenance)"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.admin_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-backend-sg", Layer = "backend" })
}

# -----------------------------
# 5) DB SG - allow MySQL from backend only
# -----------------------------
resource "aws_security_group" "db_sg" {
  name        = "${local.name_prefix}-db-sg"
  description = "RDS / DB servers - allow MySQL only from backend servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from backend servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-db-sg", Layer = "db" })
}
