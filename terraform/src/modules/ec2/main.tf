data "aws_ami" "ubuntu_22" {
  most_recent = true
  owners      = ["099720109477"] # Canonical official AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

##############################################
# EC2 Module - main.tf
# Purpose:
#   Create a single EC2 instance (Frontend or Backend)
#   with clean, production-friendly configuration.
#   Works for both public and private subnets.
##############################################

# ----------------------------------------------------
# 1️⃣ EC2 Instance Resource
# ----------------------------------------------------
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.ubuntu_22.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  # Attach a Name tag + other custom tags
  tags = merge(
    var.tags,
    {
      Name = var.instance_name
    }
  )

  # Enable detailed monitoring for better visibility
  monitoring = true

  # Optional user_data can be passed for initial setup (e.g., Ansible or shell)
#   user_data = var.user_data != "" ? var.user_data : null

  # To ensure EC2 is replaced only when required (safe provisioning)
  lifecycle {
    create_before_destroy = true
  }
}

# ----------------------------------------------------
# 2️⃣ Elastic IP for Public EC2 (Optional)
# Only created if the EC2 is in a public subnet and allocate_eip = true
# ----------------------------------------------------
# Optionally Allocate and Associate Elastic IP
resource "aws_eip" "public_eip" {
  count = var.allocate_eip ? 1 : 0

  instance = aws_instance.ec2_instance.id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.instance_name}-eip"
    }
  )
}


# ----------------------------------------------------
# 3️⃣ Output Helpful Information Locally
# ----------------------------------------------------
output "instance_summary" {
  value = {
    instance_name  = var.instance_name
    instance_id    = aws_instance.ec2_instance.id
    instance_type  = aws_instance.ec2_instance.instance_type
    private_ip     = aws_instance.ec2_instance.private_ip
    public_ip      = var.allocate_eip ? aws_eip.public_eip[0].public_ip : aws_instance.ec2_instance.public_ip
    subnet_id      = var.subnet_id
  }
}
