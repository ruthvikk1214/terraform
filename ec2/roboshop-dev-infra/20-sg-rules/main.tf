resource "aws_security_group_rule" "bastion_internet" { #bastion accepting connection from internet
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
#   cidr_blocks       = [0.0.0.0/0]
  cidr_blocks       = [local.my_ip]
  security_group_id = local.bastion_sg_id
}

resource "aws_security_group_rule" "mongob_bastion" {#mongo accepting connection from bastion
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = data.aws_ssm_parameter.bastion_sg_id.value
  security_group_id = local.mongodb_sg_id
}
resource "aws_security_group_rule" "mongodb_catalogue" {#mongo accepting connection from catalogue
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  source_security_group_id = data.aws_ssm_parameter.catalogue_sg_id.value
  security_group_id = local.mongodb_sg_id
}
