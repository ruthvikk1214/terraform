module "sg" {
  count = length(var.sg_names)
  source      = "../../terraform-aws-sg"
  project     = var.project
  environment = var.environment
  sg_name     = var.sg_names[count.index]
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
}