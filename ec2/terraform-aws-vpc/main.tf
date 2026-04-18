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
    
  }
}

# Subnet within the main VPC
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
   ## count = length(var.public_subnet_cidr)

  cidr_block = var.public_subnet_cidr
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${var.project}-${var.environment}"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
    ##count = length(var.private_subnet_cidr)

  cidr_block = var.private_subnet_cidr
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "private-subnet-${var.project}-${var.environment}"
  }
}