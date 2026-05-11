data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}
output "my_ip" {
  value = chomp(data.http.my_public_ip_v4.response_body)
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project}/${var.environment}/vpc_id"
}