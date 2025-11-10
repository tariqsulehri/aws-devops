##############################################
# Terraform & AWS Provider Configuration
##############################################

# required_providers ensures consistent AWS provider version.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure AWS provider to use local credentials
provider "aws" {
  region = var.aws_region
}
