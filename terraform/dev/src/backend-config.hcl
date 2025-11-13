    bucket         = "tf-state-bucket-ci-cd"
    key            = "infra/terraform.tfstate"
    region         = "eu-north-1"
    # dynamodb_table = "terraform-state-locking"
    # use_lockfile = true
    encrypt        = true