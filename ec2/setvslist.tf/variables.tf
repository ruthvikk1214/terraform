variable "fruit" {
  type = list(string)
  default = [ "apple", "banana", "grapes", "orange", "apple" ]
}

output "cars" {
  value = var.cars
}

variable "cars" {
  type = set(string)
default = [ "kia", "honda", "audi", "bmw", "kia", "honda" ]

}