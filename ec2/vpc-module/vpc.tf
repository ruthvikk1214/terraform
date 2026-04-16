module "vpc" {
  source = "../terraform-aws-vpc"
  
  project     = "roboshop"
  environment = "dev"
}