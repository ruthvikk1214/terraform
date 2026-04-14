terraform {
  backend "s3" {
    bucket  = "rk1214-dev"
    key     = "rk1214-remote-state.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}