# output for VPC ID
output "vpc_id" {
  value = aws_vpc.cloudreality-vpc.id
}

# output for public subnet IDs
output "public_subnet_ids" {
  value = aws_subnet.public-subnet[*].id
}

# output for private subnet IDs
output "private_subnet_ids" {
  value = aws_subnet.private-subnet[*].id
}

# output for internet gateway ID
output "internet_gateway_id" {
  value = aws_internet_gateway.cloudreality-vpc.id
}

# output for public route table ID
output "public_route_table_id" {
  value = aws_route_table.public-rt.id
}

# output for private route table ID
output "private_route_table_id" {
  value = aws_route_table.private-rt.id
} 

# output for public subnet CIDRs
output "public_subnet_cidrs" {
  value = var.public_subnets
}

# output for private subnet CIDRs
output "private_subnet_cidrs" {
  value = var.private_subnets
}

# output for availability zones
output "availability_zones" {
  value = var.azs
}

