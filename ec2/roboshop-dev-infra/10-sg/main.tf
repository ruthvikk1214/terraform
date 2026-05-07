module "sg" {
  source      = "../../terraform-aws-sg"
  project     = var.project
  environment = var.environment
  sg_name     = "mongodb"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
}