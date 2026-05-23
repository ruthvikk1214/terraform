locals {
  #  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = {
    project     = var.project
    environment = var.environment
    terraform   = true
  }
}
