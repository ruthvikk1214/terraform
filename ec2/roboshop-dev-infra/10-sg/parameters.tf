resource "aws_ssm_parameter" "sg_id" {
  count = length(module.sg)

  name  = "/${var.project}/${var.environment}/${var.sg_names[count.index]}_sg_id"
  type  = "String"
 value = module.sg[var.sg_names[count.index]].sg_id
}