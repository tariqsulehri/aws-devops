##############################################
# MAIN - Create a VPC with public & private subnets
# Includes:
# - VPC
# - Internet Gateway
# - NAT Gateways (1 per AZ)
# - Public and Private Route Tables
# - Routes for internet and private traffic
##############################################

locals {
  name_prefix = "${var.project_name}-${var.env}"
}

# 1️⃣ Create the VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    { Name = "${local.name_prefix}-vpc" }
  )
}

# 2️⃣ Create the Internet Gateway for public subnets
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(
    var.tags,
    { Name = "${local.name_prefix}-igw" }
  )
}

# 3️⃣ Create Public Subnets (for frontend, load balancers, etc.)
resource "aws_subnet" "public_subnets" {
  for_each = zipmap(var.availability_zones, var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true # Automatically assigns public IP to instances

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-public-${each.key}"
      Tier = "public"
    }
  )
}

# 4️⃣ Create Private Subnets (for backend, RDS, etc.)
##############################################
# Create Private Subnets (1 per AZ)
##############################################
resource "aws_subnet" "private_subnets" {
  for_each = zipmap(var.availability_zones, var.private_subnet_cidrs)

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.env}-private-${each.key}"
    Tier = "private"
  })
}

# 5️⃣ Create an Elastic IP and NAT Gateway in each public subnet
resource "aws_eip" "nat_eip" {
  for_each = aws_subnet.public_subnets

  domain = "vpc"

  tags = merge(
    var.tags,
    { Name = "${local.name_prefix}-nat-eip-${each.key}" }
  )
}

resource "aws_nat_gateway" "nat_gateways" {
  for_each = aws_subnet.public_subnets

  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = each.value.id

  tags = merge(
    var.tags,
    { Name = "${local.name_prefix}-nat-${each.key}" }
  )

  depends_on = [aws_internet_gateway.internet_gateway]
}

# 6️⃣ Create a single Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(
    var.tags,
    { Name = "${local.name_prefix}-public-rt" }
  )
}

# Add route to Internet via IGW
resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# Associate all public subnets with public route table
resource "aws_route_table_association" "public_associations" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

# 7️⃣ Create Private Route Tables — one per AZ
resource "aws_route_table" "private_route_tables" {
  for_each = aws_nat_gateway.nat_gateways

  vpc_id = aws_vpc.main_vpc.id

  tags = merge(
    var.tags,
    { Name = "${local.name_prefix}-private-rt-${each.key}" }
  )
}

# Add default route to NAT for private subnets
resource "aws_route" "private_nat_routes" {
  for_each               = aws_route_table.private_route_tables
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateways[each.key].id
}

# Associate private subnets with private route tables
resource "aws_route_table_association" "private_associations" {
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_tables[each.key].id
}
