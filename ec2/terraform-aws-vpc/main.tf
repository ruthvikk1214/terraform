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
   tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-igwy"
  })
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  count = length(var.public_subnet_cidrs)
  cidr_block = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-public-subnet"
  })
}
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  count = length(var.private_subnet_cidrs)
  cidr_block = var.private_subnet_cidrs[count.index]
  map_public_ip_on_launch = false
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-subnet"
  })
}
resource "aws_subnet" "database" {
  vpc_id     = aws_vpc.main.id
  count = length(var.database_subnet_cidrs)
  cidr_block = var.database_subnet_cidrs[count.index]
  map_public_ip_on_launch = false
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-database-subnet"
  })
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "10.0.1.0/24"
    #gateway_id = aws_internet_gateway.main
  }

  /*route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }*/

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-public-route-table"
  })
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

 route {
    cidr_block = "10.0.2.0/24"
     /*gateway_id = aws_internet_gateway.main
  }*/

 /* route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }*/
 }
  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-route-table"
  })          
}
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "10.0.3.0/24"
    
  }

  /*route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }*/

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-database-route-table"
  })  
}

resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id

}

resource "aws_eip" "nat" {
  domain                    = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-nat-eip"
  })
}