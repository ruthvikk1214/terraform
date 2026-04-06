variable "instances" {
  type = map(string)
  default = {
    "mongodb" = "t3.micro"
    "redis"   = "t3.micro"
    "mysql"   = "t3.small"
  }
}

variable "zoneid" {
  type = string
  default = "Z031906510N5GWM6MW07L"
}

variable "domain_name" {
  default = rk1214.in
}