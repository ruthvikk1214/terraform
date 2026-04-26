module "vpc" {
  source = "../terraform-aws-vpc"
  
  project     = "roboshop"
  environment = "dev"
  is_peering_needed = true
}

