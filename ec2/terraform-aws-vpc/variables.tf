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
variable "public_subnet_cidrs" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_subnet_cidrs" {
  type = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}
variable "database_subnet_cidrs" {
  type = list(string)
  default = ["10.0.5.0/24", "10.0.6.0/24"]
}
variable "availability_zones" {
  type = list(string)
  default = [ "us-east-1a", "us-east-1b" ]
}
variable "public_route_table_tags" {
  type = map(string)
  default = {}
}
variable "private_route_table_tags" {
  type = map(string)
  default = {}
}
variable "database_route_table_tags" {
  type = map(string)
  default = {}
}