##############################################
# Terraform & AWS Provider Configuration
##############################################

# required_providers ensures consistent AWS provider version.
terraform {

  backend "s3" {
    bucket = "tf-state-bucket-ci-cd"
    key = "tf-infra/terraform.tfstate"
    region =  "eu-north-1"
    dynamodb_table = "terraform-state-locking"
  }

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
