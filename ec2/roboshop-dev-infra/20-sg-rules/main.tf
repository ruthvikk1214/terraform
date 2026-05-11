resource "aws_security_group_rule" "bastion_internet" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
#   cidr_blocks       = [0.0.0.0/0]
  cidr_blocks       = [local.my_ip]
  ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = "sg-123456"
}

resource "aws_security_group_rule" "mongo_bastion" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.example.cidr_block]
  ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = "sg-123456"
}