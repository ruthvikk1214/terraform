resource "aws_route53_record" "example" {
  zone_id = rk1214.in
  count = 10
  name    = "www.example.com"
  type    = "A"
  ttl     = 1
  records = var.instances[count.index]
}