resource "aws_lb" "backend-alb" {
  name               = "${var.project}-${var.environment}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [local.backend_alb_sg_id]
  subnets            = local.private_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-backend-alb"
    },
    local.common_tags
  )
}

resource "aws_lb_listener" "HTTP" {
  load_balancer_arn = aws_lb.backend-alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      message_body = "<h1> Backend ALB is working fine</h1>"
      status_code  = "200"
    }
  }
}
resource "aws_route53_record" "backend_alias" {
  zone_id = var.zone_id
  name    = "*.backend-alb-${var.environment}.${var.domain_name}" # The DNS name you want to use
  type    = "A"                                                   # Use "A" for IPv4 or "AAAA" for IPv6

  alias {
    # Reference the ALB's DNS name and Hosted Zone ID
    name                   = aws_lb.backend-alb.dns_name
    zone_id                = aws_lb.backend-alb.zone_id
    evaluate_target_health = true # Recommended to let Route 53 check ALB health
  }
}
