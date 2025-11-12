terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # backend "s3" {
  #   bucket         = "tf-state-bucket-ci-cd"
  #   key            = "infra/terraform.tfstate"
  #   region         = "eu-north-1"
  #   # dynamodb_table = "terraform-state-locking"
  #   # use_lockfile   = true
  #   encrypt        = true
  # }
}
