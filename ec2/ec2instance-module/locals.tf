locals {
  common_tags = {
    Project = var.project
    Environment = var.environment
    Terraform = true
  }
  ec2_final_tags = merge(
    local.common_tags
  )
}