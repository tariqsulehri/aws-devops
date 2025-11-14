###############################################################
# ROOT MAIN.TF
# Purpose: Connect and orchestrate reusable modules
# Environment: Production / Staging
###############################################################

###############################################################
# 0️⃣ Terraform State Backend Module
# Creates S3 + DynamoDB for remote backend
###############################################################
module "tf_state" {
  source              = "./modules/tf-state"
  bucket_name         = "tf-state-bucket-ci-cd"
  dynamodb_table_name = "terraform-state-locking"
  force_destroy       = true
}

###############################################################
# 1️⃣ Networking Layer - VPC
# Creates VPC, subnets, IGW, NAT, route tables
###############################################################
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  env          = var.env
  tags         = var.tags

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

###############################################################
# 2️⃣ Security Layer – Security Groups
# Admin SG, Web SG, Backend SG, ALB SG, DB SG
###############################################################
module "security_groups" {
  source       = "./modules/security-groups"
  project_name = var.project_name
  env          = var.env
  vpc_id       = module.vpc.vpc_id
  admin_ip     = var.admin_ip
  app_port     = var.app_port
  tags         = var.tags
}

###############################################################
# 3️⃣ CDN Layer – S3 + CloudFront for Frontend Hosting
###############################################################
module "s3_cloudfront" {
  source       = "./modules/s3_cloudfront"
  project_name = var.project_name
  env          = var.env
  tags         = var.tags
}

###############################################################
# 4️⃣ Compute Layer – Frontend EC2 (Public Subnet)
###############################################################
module "frontend_ec2" {
  source        = "./modules/ec2"

  project_name  = var.project_name
  instance_name = "${var.project_name}-frontend"
  instance_type = "t3.micro"
  key_name      = "web_server_key"
  env           = var.env

  subnet_id = module.vpc.public_subnet_ids[0]

  security_group_ids = [
    module.security_groups.admin_sg_id, # SSH access
    module.security_groups.web_sg_id    # HTTP/HTTPS access
  ]

  tags = merge(var.tags, { Role = "Frontend" })
}

###############################################################
# 5️⃣ Compute Layer – Backend EC2 (Private Subnet)
###############################################################
module "backend_ec2" {
  source        = "./modules/ec2"

  project_name  = var.project_name
  instance_name = "${var.project_name}-backend"
  instance_type = "t3.micro"
  key_name      = "web_server_key"
  env           = var.env

  subnet_id = module.vpc.private_subnet_ids[0]

  security_group_ids = [
    module.security_groups.admin_sg_id,  # Bastion / VPN SSH access
    module.security_groups.backend_sg_id # Internal API access
  ]

  tags = merge(var.tags, { Role = "Backend" })
}

###############################################################
# 6️⃣ Load Balancing Layer – Application Load Balancer (Public)
###############################################################
locals {
  instance_map = {
    backend1 = module.backend_ec2.ec2_instance_id
  }
}

module "alb" {
  source             = "./modules/alb"
  project_name       = var.project_name
  env                = var.env
  vpc_id             = module.vpc.vpc_id

  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_ids = [module.security_groups.alb_sg_id]

  instance_map       = local.instance_map
  target_port        = var.app_port
  health_check_path  = "/health"
  enable_https       = false

  tags = var.tags
}

###############################################################
# Optional – 7️⃣ RDS (Private DB)
###############################################################
# module "rds" {
#   source             = "./modules/rds"
#   project_name       = var.project_name
#   env                = var.env
#   db_name            = "devops_db"
#   username           = "admin"
#   password           = "MySql#Prod1!"
#   private_subnet_ids = module.vpc.private_subnet_ids
#   security_group_ids = [module.security_groups.db_sg_id]
#   tags               = var.tags
# }
