locals {
  bastion_sg_id =   data.aws_ssm_parameter.bastion_sg_id.value
  mongodb_sg_id =   data.aws_ssm_parameter.mongodb_sg_id.value
  ami_id   =    data.aws_ami.joindevops.id
   rabbitmq_sg_id =   data.aws_ssm_parameter.rabbitmq_sg_id.value
   redis_sg_id =   data.aws_ssm_parameter.redis_sg_id.value
   catalogue_sg_id  = data.aws_ssm_parameter.catalogue_sg_id
   mysql_sg_id =   data.aws_ssm_parameter.mysql_sg_id.value
   user_sg_id = data.aws_ssm_parameter.user_sg_id
   cart_sg_id = data.aws_ssm_parameter.cart_sg_id
   frontend_sg_id =  data.aws_ssm_parameter.frontend_sg_id
   payment_sg_id  =  data.aws_ssm_parameter.payment_sg_id
   shipping_sg_id = data.aws_ssm_parameter.shipping_sg_id
  database_subnet_ids = split(",", data.aws_ssm_parameter.database_subnet_ids.value)[0]
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
  public_subnet_ids = split(",", data.aws_ssm_parameter.public_subnet_ids.value)[0]
  common_tags  =    {
    project =   var.project
    environment =   var.environment
    terraform   =   true
}
}