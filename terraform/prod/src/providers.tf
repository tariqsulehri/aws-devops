##############################################
# Terraform & AWS Provider Configuration
##############################################

# required_providers ensures consistent AWS provider version.

# Configure AWS provider to use local credentials
provider "aws" {
  region = var.aws_region
}
