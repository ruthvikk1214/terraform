variable "instances" {
  type = map(string)
  default = {
    "mongodb" = "t3.micro"
    "redis"   = "t3.micro"
    "mysql"   = "t3.small"
  }
}