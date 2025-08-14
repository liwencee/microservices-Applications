data "aws_availability_zones" "available" {}

locals {
  azs = length(var.azs) > 0 ? var.azs : slice(data.aws_availability_zones.available.names, 0, 3)
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge({
    Name = "eks-vpc"
  }, var.tags)
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "eks-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "eks-public-rt"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Create public subnets
resource "aws_subnet" "public" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-${count.index}"
  }
}

# Create NAT Gateways and Private subnets (1 NAT per AZ)
resource "aws_eip" "nat" {
  count = length(local.azs)
  vpc   = true
  tags = {
    Name = "nat-eip-${count.index}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(local.azs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.igw]

  tags = { Name = "eks-nat-${count.index}" }
}

resource "aws_subnet" "private" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]
  tags = {
    Name = "eks-private-${count.index}"
  }
}

resource "aws_route_table" "private_rt" {
  count  = length(local.azs)
  vpc_id = aws_vpc.this.id
  tags = { Name = "eks-private-rt-${count.index}" }
}

resource "aws_route" "private_nat_route" {
  count                  = length(local.azs)
  route_table_id         = aws_route_table.private_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "public_association" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_association" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}
