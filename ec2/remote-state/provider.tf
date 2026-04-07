terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.39.0"
    }
  }
   backend "s3" {
    bucket         = "rk1214-remote-state"
    key            = "network/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table" # Optional: for locking
    encrypt        = true                   # Recommended
  }
}

provider "aws" {
  # Configuration options
}