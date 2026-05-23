resource "aws_lb" "frontend-alb" {
  name               = "${var.project}-${var.environment}-frontend"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [local.frontend_alb_sg_id]
  subnets            = local.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-frontend-alb"
    },
    local.common_tags
  )
}

resource "aws_lb_listener" "HTTP" {
  load_balancer_arn = aws_lb.frontend-alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = local.acm_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      message_body = "<h1> Frontend ALB is working fine</h1>"
      status_code  = "200"
    }
  }
}
resource "aws_route53_record" "frontend_alias" {
  zone_id = var.zone_id
  name    = "*.frontend-alb-${var.project}-${var.environment}.${var.domain_name}" # The DNS name you want to use
  type    = "A"                                                                   # Use "A" for IPv4 or "AAAA" for IPv6

  alias {
    # Reference the ALB's DNS name and Hosted Zone ID
    name                   = aws_lb.frontend-alb.dns_name
    zone_id                = aws_lb.frontend-alb.zone_id
    evaluate_target_health = true # Recommended to let Route 53 check ALB health
  }
}
