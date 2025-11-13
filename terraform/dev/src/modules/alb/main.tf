##############################################
# MODULE: ALB (Application Load Balancer)
# PURPOSE: Create an Internet-facing ALB with Target Groups
#          that forward traffic to backend EC2 instances
# AUTHOR: DevOps Team
##############################################

# -----------------------------
# 1️⃣ Create ALB
# -----------------------------
resource "aws_lb" "backend_node_alb" {
  name               = "${var.project_name}-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.env}-alb"
  })
}

# -----------------------------
# 2️⃣ Create Target Group
# -----------------------------
resource "aws_lb_target_group" "backend_node_tg" {
  name     = "${var.project_name}-${var.env}-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = var.health_check_path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.env}-tg"
  })
}

# -----------------------------
# 3️⃣ Attach EC2 Instances to Target Group
# -----------------------------
resource "aws_lb_target_group_attachment" "backend_node_assoc_tg" {
  # for_each = toset(var.instance_ids)
  for_each = var.instance_map

  target_group_arn = aws_lb_target_group.backend_node_tg.arn
  target_id        = each.value
  port             = 3500
}

# -----------------------------
# 4️⃣ Create ALB Listener (HTTP → Target Group)
# -----------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.backend_node_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_node_tg.arn
  }
}

# -----------------------------
# 5️⃣ (Optional) HTTPS Listener
# -----------------------------
resource "aws_lb_listener" "https" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.backend_node_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_node_tg.arn
  }
}




