resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-vpc"
  })
}

# Internet gateway attached to the main VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-${var.environment}-igwy"
    map_public_ip_on_launch = true
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  count = length(var.public_subnet_cidrs)
  cidr_block = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "Main"
  }
}
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  count = length(var.private_subnet_cidrs)
  cidr_block = var.private_subnet_cidrs[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "Main"
  }
}
resource "aws_subnet" "database" {
  vpc_id     = aws_vpc.main.id
  count = length(var.database_subnet_cidrs)
  cidr_block = var.database_subnet_cidrs[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "Main"
  }
}