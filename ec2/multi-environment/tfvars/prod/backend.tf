terraform {
  backend "s3" {
    bucket         = "rk1214-prod"
    key            = "remote-state.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}