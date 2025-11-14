##############################################
# ROOT MAIN.TF
# Purpose: Connect and orchestrate reusable modules
# Environment: Production / Staging
##############################################


# ----------------------------------------------------
# 2️⃣ VPC Module
# Creates a VPC, public + private subnets, and outputs IDs
# ----------------------------------------------------
# VPC module (keeps the same inputs you were using)
module "tf_state" {
  source              = "./modules/tf-state"
  bucket_name         = "tf-state-bucket-ci-cd"
  dynamodb_table_name = "terraform-state-locking"
  force_destroy       = true
}


# --------------------------------------------------------------------------------
# 4️⃣ Cloudfront Module for Frontend (React)
# Creates S3 bucket to store react file that could accessable through could front
# --------------------------------------------------------------------------------
module "s3_cloudfront" {
  source       = "./modules/s3_cloudfront"
  project_name = var.project_name
  env          = var.env
  tags         = var.tags
}



##############################################
# ROOT MAIN - module wiring
##############################################

module "vpc" {
  source = "./modules/vpc"
  # naming + tags
  project_name = var.project_name
  env          = var.env
  tags         = var.tags
  # networking
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs


}

# ----------------------------------------------------
# 3️⃣ Security Groups Module
# Creates Admin, Web, and Backend Security Groups
# ----------------------------------------------------


module "security_groups" {
  source       = "./modules/security-groups"
  project_name = var.project_name
  env          = var.env
  vpc_id       = module.vpc.vpc_id
  admin_ip     = var.admin_ip
  app_port     = var.app_port
  tags         = var.tags
}


# ----------------------------------------------------
# 4️⃣ EC2 Module for Frontend (React)
# Creates EC2 instance in public subnet
# ----------------------------------------------------
module "frontend_ec2" {
  source        = "./modules/ec2"
  instance_type = "t3.micro"
  key_name      = "web_server_key"
  project_name  = var.project_name
  instance_name = "${var.project_name}-frontend"
  subnet_id     = module.vpc.public_subnet_ids[0]
  env           = var.env
  # Networking configuration
  # subnet_id          = element(module.vpc.public_subnet_ids, 0)
  security_group_ids = [
    module.security_groups.admin_sg_id, # Optional SSH/Admin Access
    module.security_groups.web_sg_id    # HTTP/HTTPS Access
  ]
  # Common tags
  tags = merge(var.tags, { Role = "Frontend" })
  # ami_id             = ""
}

# ----------------------------------------------------
# 5️⃣ EC2 Module for Backend (Node.js)
# Creates EC2 instance in private subnet
# ----------------------------------------------------
module "backend_ec2" {
  source        = "./modules/ec2"
  project_name  = var.project_name
  instance_name = "${var.project_name}-backend"
  instance_type = "t3.micro"
  key_name      = "web_server_key"
  subnet_id     = module.vpc.private_subnet_ids[0]
  env           = var.env
  # Networking configuration
  # subnet_id           = element(module.vpc.private_subnet_ids, 0)
  security_group_ids = [
    module.security_groups.admin_sg_id,  # Optional SSH Access (via Bastion or VPN)
    module.security_groups.backend_sg_id # Internal API Access
  ]
  # Common tags
  tags = merge(var.tags, { Role = "Backend" })
}


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
  tags               = var.tags
}


# ----------------------------------------------------
# 6️⃣ RDS Module (MySQL)
# Creates private RDS accessible only from Backend SG
# ----------------------------------------------------

# module "rds" {
#   source             = "./modules/rds"
#   project_name       = var.project_name
#   private_subnet_ids = module.vpc.private_subnet_ids
#   security_group_ids = [module.security_groups.db_sg_id] # or relevant SG for DB
#   env                =  var.env
#   db_name            = "devops_db"
#   username           = "admin"
#   password           = "MySql#Prod1!"
#   tags               = var.tags
# }