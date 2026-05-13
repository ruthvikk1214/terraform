module "sg" {
for_each = toset(var.sg_names)
  source      = "../../terraform-aws-sg"
  project     = var.project
  environment = var.environment
  sg_name = each.value
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
}