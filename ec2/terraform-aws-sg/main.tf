resource "aws_security_group" "main" {
  name        = "${var.sg_name}-${var.project}-${var.environment}"
  description = "Allow TLS inbound traffic for ${var.project} in ${var.environment} for ${var.sg_name}"
  vpc_id      = var.vpc_id

  tags = merge(

    local.common_tags,
    {
      Name = "${var.sg_name}-${var.project}-${var.environment}"
    },
    var.sg_tags
  )

}
