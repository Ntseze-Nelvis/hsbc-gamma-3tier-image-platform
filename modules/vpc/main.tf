# create a vpc
resource "aws_vpc" "cloudreality-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# create an igw
resource "aws_internet_gateway" "cloudreality-vpc" {
  vpc_id = aws_vpc.cloudreality-vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# create public subnet
resource "aws_subnet" "public-subnet" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.cloudreality-vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}
# create public route table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.cloudreality-vpc.id

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# associate public subnet with route table
resource "aws_route_table_association" "public-rt-assoc" {
  count          = length(aws_subnet.public-subnet)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public-rt.id
}

# create route to igw in public route table
resource "aws_route" "public-route" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cloudreality-vpc.id
} 

# create private subnet
resource "aws_subnet" "private-subnet" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.cloudreality-vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
  }
}

# create private route table
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.cloudreality-vpc.id

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# associate private subnet with route table
resource "aws_route_table_association" "private-rt-assoc" {
  count          = length(aws_subnet.private-subnet)
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private-rt.id
}

# Note: No routes to IGW in private route table
# Private subnets do not have direct internet access

# create nat gateway 
resource "aws_eip" "nat-eip" {
domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
} 

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-subnet[0].id

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }
}


# create route to nat gateway in private route table
resource "aws_route" "private-route" {
  route_table_id         = aws_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gateway.id
} 


