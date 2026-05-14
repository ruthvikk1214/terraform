locals {
    my_ip = "${chomp(data.http.my_ip.response_body)}/32"
  bastion_sg_id = data.aws_ssm_parameter.bastion_sg_id.value
  mongodb_sg_id = data.aws_ssm_parameter.mongod_sg_id.value
  catalogue_sg_id = data.aws_ssm_parameter.catalogue_sg_id.value
}
