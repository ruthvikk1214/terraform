data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_vpc" "default_vpc_id" {
  default = true
}
data "aws_vpc" "default_vpc_id" {
  # Filter by ID or another attribute
  id = aws_vpc.main.id
}

output "main_route_table_id" {
  value = data.aws_vpc.default_vpc_id.main_route_table_id
}
