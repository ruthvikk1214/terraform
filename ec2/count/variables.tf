variable "instances" {
 type = list
 default = ["mongodb", "redis", "mysql", "frontend", "backend", "cart", "catalogue", "payment", "shipping", "user","rabbitmq"]

}