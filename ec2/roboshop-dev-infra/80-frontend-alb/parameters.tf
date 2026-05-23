resource "aws_ssm_parameter" "backend-alb_listener_arn" {
  name        = "/${var.project}/${var.environment}/backend-alb_listener_arn"
  type        = "String"
  description = "Listener ARN for the backend ALB"
  value       = aws_lb_listener.HTTP.arn
}
