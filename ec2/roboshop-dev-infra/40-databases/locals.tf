locals {
  bastion_sg_id =   data.aws_ssm_parameter.bastion_sg_id.value
  mongodb_sg_id =   data.aws_ssm_parameter.mongodb_sg_id.value
  ami_id   =    data.aws_ami.joindevops.id
   rabbitmq_sg_id =   data.aws_ssm_parameter.rabbitmq_sg_id.value
   redis_sg_id =   data.aws_ssm_parameter.redis_sg_id.value
   mysql_sg_id =   data.aws_ssm_parameter.mysql_sg_id.value
  database_subnet_ids = split(",", data.aws_ssm_parameter.database_subnet_ids.value)[0]
mysql_role_name = join("-", [
            for name in ["${var.project}","${var.environment}", "mysql"] : title(name)
        ])
    mysql_policy_name = join("", [
            for name in ["${var.project}","${var.environment}", "mysql"] : title(name)
        ])

  common_tags  =    {
    project =   var.project
    environment =   var.environment
    terraform   =   true
}
}