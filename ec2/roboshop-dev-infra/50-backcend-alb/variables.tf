variable "project" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

variable "zone_id" {
  default = "Z031906510N5GWM6MW07L"
} 

variable "domain_name" {
  default = "rk1214.in"
}
variable "mysql_root_password" {
  default   = "DevOps321"
  sensitive = true
}