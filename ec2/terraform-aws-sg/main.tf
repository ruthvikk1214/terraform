resource "aws_security_group" "main" {
  name        = "${var.sg_name}-${var.project}-${var.environment}"
  description = "Allow TLS inbound traffic for ${var.project} in ${var.environment} for ${var.sg_name}"
  vpc_id      = var.vpc_id
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.sg_name}-${var.project}-${var.environment}"
    },
    var.sg_tags
  )

}
