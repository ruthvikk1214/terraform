variable "project" {
  default = "roboshop"
}
variable "environment" {
  default = "dev"
}
variable "sg_names" {
  type = list(string)

  default = [
    "mongod",
    "redis",
    "mysql",
    "rabbitmq",
    "cart",
    "catalogue",
    "user",
    "shipping",
    "payment",
    "frontend",
    "backend_alb",
    "frontend_alb",
    "bastion"
  ]
}