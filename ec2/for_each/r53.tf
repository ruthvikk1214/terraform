resource "aws_route53_record" "roboshop" {
  zone_id = var.zoneid
  for_each = aws_instance.roboshop
  name    = "${each.key}.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.roboshop[each.key].private_ip]
  allow_overwrite = true
}