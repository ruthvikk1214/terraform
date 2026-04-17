variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default = "10.0.0.0/16"
}
variable "project" {
  type = string
}   
variable "environment" {
  type = string
}
variable "igwy_tags" {
  type = map
  default = {}
}
variable "public_subnet_cidr" {
  type = string
  default = "10.0.1.0/24"
}
variable "private_subnet_cidr" {
  type = string
  default = "10.0.2.0/24"
}