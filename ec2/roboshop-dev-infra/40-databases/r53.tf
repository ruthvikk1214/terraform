resource "aws_route53_record" "mongodb" {
  zone_id = var.zone_id
  name    = "mongodb-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = "1"   
  records = [aws_instance.mongodb.private_ip]
  allow_overwrite = true
}

resource "aws_route53_record" "redis" {
  zone_id = var.zone_id
  name    = "redis-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = "1" 
  records = [aws_instance.redis.private_ip]
  allow_overwrite = true
}
resource "aws_route53_record" "rabbitmq" {
  zone_id = var.zone_id
  name    = "rabbitmq-${var.environment}.${var.domain_name}"
  type    = "A"   
  ttl     = "1"
  records = [aws_instance.rabbitmq.private_ip]
  allow_overwrite = true
}
resource "aws_route53_record" "mysql" {
  zone_id = var.zone_id                        
  name    = "mysql-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = "1"
  records = [aws_instance.mysql.private_ip]
  allow_overwrite = true
}
/*
resource "aws_route53_record" "user" {
  zone_id = var.zone_id
  name    = "user-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = "1"   
  records = [aws_instance.user.private_ip]
  allow_overwrite = true
}
resource "aws_route53_record" "cart" {
  zone_id = var.zone_id
  name    = "cart-${var.environment}.${var.domain_name}"
  type    = "A"   
  ttl     = "1"
  records = [aws_instance.cart.private_ip]
  allow_overwrite = true
}
resource "aws_route53_record" "shipping" {
  zone_id = var.zone_id
  name    = "shipping-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = "1"  
  records = [aws_instance.shipping.private_ip]
  allow_overwrite = true
}
resource "aws_route53_record" "catalogue" {
  zone_id = var.zone_id
  name    = "catalogue-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = "1"  
  records = [aws_instance.catalogue.private_ip]
  allow_overwrite = true
}
resource "aws_route53_record" "payment" {   
  zone_id = var.zone_id
  name    = "payment-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = "1"
  records = [aws_instance.payment.private_ip]
  allow_overwrite = true
}
resource "aws_route53_record" "frontend" {
  zone_id = var.zone_id
  name    = "frontend-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = "1"
  records = [aws_instance.frontend.private_ip] 
  allow_overwrite = true
}
*/