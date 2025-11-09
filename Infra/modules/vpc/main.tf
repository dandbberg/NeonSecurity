resource "aws_vpc" "dberg_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "dberg-vpc"
  }
}

resource "aws_internet_gateway" "dberg_igw" {
  vpc_id = aws_vpc.dberg_vpc.id

  tags = {
    Name = "dberg-igw"
  }
}

resource "aws_subnet" "dberg_subnet_public" {
  count                   = length(var.azs)
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  vpc_id                  = aws_vpc.dberg_vpc.id
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "dberg-sub-public-${var.azs[count.index]}"
  }
}

resource "aws_subnet" "dberg_subnet_private" {
  count             = length(var.azs)
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  vpc_id            = aws_vpc.dberg_vpc.id
  availability_zone = var.azs[count.index]

  tags = {
    Name = "dberg-sub-private-${var.azs[count.index]}"
  }
}

resource "aws_eip" "dberg_eip" {
  count      = length(var.azs)
  depends_on = [aws_internet_gateway.dberg_igw]

  tags = {
    Name = "dberg-eip-${count.index}"
  }
}

resource "aws_nat_gateway" "dberg_nat_gw" {
  count         = length(var.azs)
  allocation_id = aws_eip.dberg_eip[count.index].id
  subnet_id     = aws_subnet.dberg_subnet_public[count.index].id

  tags = {
    Name = "path-nat-gw-${count.index}"
  }
}

resource "aws_route_table" "dberg_public_rt" {
  vpc_id = aws_vpc.dberg_vpc.id

  tags = {
    Name = "dberg-public-rt"
  }
}

resource "aws_route" "dberg_public_route" {
  route_table_id         = aws_route_table.dberg_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dberg_igw.id
}

resource "aws_route_table_association" "dberg_public_association" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.dberg_subnet_public[count.index].id
  route_table_id = aws_route_table.dberg_public_rt.id
}

# One private route table per AZ
resource "aws_route_table" "dberg_private_rt" {
  count  = length(var.azs)
  vpc_id = aws_vpc.dberg_vpc.id

  tags = {
    Name = "dberg-private-rt-${var.azs[count.index]}"
  }
}

# Each private route table routes 0.0.0.0/0 to its AZ's NAT Gateway
resource "aws_route" "dberg_private_route" {
  count                  = length(var.azs)
  route_table_id         = aws_route_table.dberg_private_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.dberg_nat_gw[count.index].id
}

# Associate each private subnet with its AZ's route table
resource "aws_route_table_association" "dberg_private_association" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.dberg_subnet_private[count.index].id
  route_table_id = aws_route_table.dberg_private_rt[count.index].id
}