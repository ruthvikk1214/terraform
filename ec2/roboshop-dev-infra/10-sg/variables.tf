variable "project" {
  default = "roboshop"
}
variable "environment" {
  default = "dev"
}
variable "sg_names" {
  type = list(
    #databases
    "mongod", "redis", "mysql","rabbitmq",
    #backend  
    "cart", "catalogue", "user", "shipping", "payment",
    #frontend
    "frontend",
    #backendalb,
    "backend_alb",
    #frontendalb,
    "frontend_alb",
    #bastion
    "bastion"

      )
}