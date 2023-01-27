resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public_subnet" {
  count = "${length(var.public_subnet_cidr_block)}"

  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${element(var.public_subnet_cidr_block, count.index)}"

  availability_zone = "${element(var.availability_zones, count.index)}"

  tags = {
    Name = "public_subnet_${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = "${length(var.private_subnet_cidr_block)}"

  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${element(var.private_subnet_cidr_block, count.index)}"

  availability_zone = "${element(var.availability_zones, count.index)}"

  tags = {
    Name = "private_subnet_${count.index}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"
}

# EIP and NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 1)}"

  depends_on = [aws_internet_gateway.igw]
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  count = "${length(aws_subnet.public_subnet.*.id)}"

  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natgw.id}"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  count = "${length(aws_subnet.private_subnet.*.id)}"

  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

output "public_subnet_ids" {
  value = "${aws_subnet.public_subnet.*.id}"
}

output "private_subnet_ids" {
  value = "${aws_subnet.private_subnet.*.id}"
}

output "id" {
  value = "${aws_vpc.main.id}"
}