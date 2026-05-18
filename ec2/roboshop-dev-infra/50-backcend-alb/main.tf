resource "aws_lb" "backend-alb" {
  name               = "${var.project}-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [local.backend_alb_sg_id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    prefix  = "${var.project}-${var.environment}-backend-alb"
    enabled = true
  }

  tags = {
    Name = "${var.project}-${var.environment}-backend-alb"
  }
}
