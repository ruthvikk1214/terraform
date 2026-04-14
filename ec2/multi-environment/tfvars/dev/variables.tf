variable "project" {
    default = "roboshop"
}

variable "instance_type" {
  default = {
    dev = "t2.micro"
    uat = "t2.small"
    prod = "t2.medium"
  }
}