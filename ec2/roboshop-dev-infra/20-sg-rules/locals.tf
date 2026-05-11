locals {
  my_ip = "${chomp(data.http.my_public_ip_v4.response_body)}/32"
}
