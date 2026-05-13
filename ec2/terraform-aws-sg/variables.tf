variable "sg_name" {
    description = "The name of the security group."
    type        = string    
}
variable "project" {
  description = "The name of the project."
  type        = string
  default     = "roboshop"
}

variable "environment" {
  description = "The deployment environment."
  type        = string
  default     = "dev"
}
variable "vpc_id" {
  type        = string
}

variable "sg_tags" {
  type = map
  default = {}
}
variable "sg_names" {
  type = list(string)

  default = [
    "mongodb",
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