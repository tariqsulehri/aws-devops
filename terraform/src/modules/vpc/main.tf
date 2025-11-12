##############################################
# MAIN - Create a VPC with public & private subnets
##############################################

locals {
  name_prefix           = "${var.project_name}-${var.env}"
  az_count              = length(var.availability_zones)
  public_subnet_count   = length(var.public_subnet_cidrs)
  private_subnet_count  = length(var.private_subnet_cidrs)
}

##############################################
# 1️⃣ Create the VPC
##############################################
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    { Name = "${local.name_prefix}-vpc" }
  )

  lifecycle {
    precondition {
      condition     = local.public_subnet_count == local.az_count
      error_message = "The number of public subnet CIDRs must match the number of availability zones."
    }
    precondition {
      condition     = local.private_subnet_count == local.az_count
      error_message = "The number of private subnet CIDRs must match the number of availability zones."
    }
  }
}

##############################################
# 2️⃣ Create the Internet Gateway
##############################################
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(
    var.tags,
    { Name = "${local.name_prefix}-igw" }
  )
}

##############################################
# 3️⃣ Create Public Subnets
##############################################
resource "aws_subnet" "public_subnets" {
  for_each = { for idx, az in var.availability_zones : az => var.public_subnet_cidrs[idx] }

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-public-${each.key}"
    Tier = "Public"
  })
}

##############################################
# 4️⃣ Create Private Subnets
##############################################
resource "aws_subnet" "private_subnets" {
  for_each = { for idx, az in var.availability_zones : az => var.private_subnet_cidrs[idx] }

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-private-${each.key}"
    Tier = "Private"
  })
}

##############################################
# 5️⃣ NAT Gateways + Elastic IPs
##############################################
resource "aws_eip" "nat_eip" {
  for_each = aws_subnet.public_subnets

  domain = "vpc"

  tags = merge(var.tags, { Name = "${local.name_prefix}-nat-eip-${each.key}" })
}

resource "aws_nat_gateway" "nat_gateways" {
  for_each = aws_subnet.public_subnets

  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = each.value.id

  tags = merge(var.tags, { Name = "${local.name_prefix}-nat-${each.key}" })

  depends_on = [aws_internet_gateway.internet_gateway]
}

##############################################
# 6️⃣ Public Route Table
##############################################
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(var.tags, { Name = "${local.name_prefix}-public-rt" })
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "public_associations" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

##############################################
# 7️⃣ Private Route Tables
##############################################
resource "aws_route_table" "private_route_tables" {
  for_each = aws_nat_gateway.nat_gateways

  vpc_id = aws_vpc.main_vpc.id

  tags = merge(var.tags, { Name = "${local.name_prefix}-private-rt-${each.key}" })
}

resource "aws_route" "private_nat_routes" {
  for_each               = aws_route_table.private_route_tables
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateways[each.key].id
}

resource "aws_route_table_association" "private_associations" {
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_tables[each.key].id
}
