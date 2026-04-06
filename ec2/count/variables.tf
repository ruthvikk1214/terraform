variable "instances" {
  type    = list(string)
  default = ["mongodb", "redis", "mysql", "frontend", "backend", "cart", "catalogue", "payment", "shipping", "user", "rabbitmq"]
}

variable "zoneid" {
  default = "Z031906510N5GWM6MW07L"
}

variable "domain_name" {
  default = "rk1214.in"
}