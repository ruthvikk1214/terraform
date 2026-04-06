resource "aws_route53_record" "roboshop" {
  zone_id = var.zoneid
  count = length(var.instances)
  name    = "${var.instances[count.index]}.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.roboshop[count.index].private_ip]
}