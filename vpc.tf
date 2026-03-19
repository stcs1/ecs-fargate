resource "aws_vpc" "dev-vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_subnet" "public-subnet-1" {
  cidr_block = "${var.public_subnet_1_cidr}"
  vpc_id = "${aws_vpc.dev-vpc.id}"
  availability_zone = "${var.region}a"
    tags = {
        Name = "public-subnet-1"
    }
}

resource "aws_subnet" "public-subnet-2" {
  cidr_block = "${var.public_subnet_2_cidr}"
  vpc_id = "${aws_vpc.dev-vpc.id}"
  map_public_ip_on_launch = true
  availability_zone = "${var.region}b"
    tags = {
        Name = "public-subnet-2"
    }
}

resource "aws_subnet" "public-subnet-3" {
  cidr_block = "${var.public_subnet_3_cidr}"
  vpc_id = "${aws_vpc.dev-vpc.id}"
  map_public_ip_on_launch = true
  availability_zone = "${var.region}c"
    tags = {
        Name = "public-subnet-3"
    }
}

resource "aws_subnet" "private-subnet-1" {
  cidr_block = "${var.public_subnet_1_cidr}"
  vpc_id = "${aws_vpc.dev-vpc.id}"
  map_public_ip_on_launch = true
  availability_zone = "${var.region}a"
    tags = {
        Name = "private-subnet-1"
    }
}

resource "aws_subnet" "private-subnet-2" {
  cidr_block = "${var.public_subnet_2_cidr}"
  vpc_id = "${aws_vpc.dev-vpc.id}"
  map_public_ip_on_launch = true
  availability_zone = "${var.region}b"
    tags = {
        Name = "private-subnet-2"
    }
}

resource "aws_subnet" "private-subnet-3" {
  cidr_block = "${var.public_subnet_3_cidr}"
  vpc_id = "${aws_vpc.dev-vpc.id}"
  map_public_ip_on_launch = true
  availability_zone = "${var.region}c"
    tags = {
        Name = "private-subnet-3"
    }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = "${aws_vpc.dev-vpc.id}"

    tags = {
        Name = "public-route-table"
    }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = "${aws_vpc.dev-vpc.id}"

    tags = {
        Name = "private-route-table"
    }
}

resource "aws_route_table_association" "public-route-table-1-association" {
  route_table_id = "${aws_route_table.public-route-table.id}"
  subnet_id = "${aws_subnet.public-subnet-1.id}"
}

resource "aws_route_table_association" "public-route-table-2-association" {
  route_table_id = "${aws_route_table.public-route-table.id}"
  subnet_id = "${aws_subnet.public-subnet-2.id}"
}

resource "aws_route_table_association" "public-route-table-3-association" {
  route_table_id = "${aws_route_table.public-route-table.id}"
  subnet_id = "${aws_subnet.public-subnet-3.id}"
}

resource "aws_route_table_association" "private-route-table-1-association" {
  route_table_id = "${aws_route_table.private-route-table.id}"
  subnet_id = "${aws_subnet.private-subnet-1.id}"
}

resource "aws_route_table_association" "private-route-table-2-association" {
  route_table_id = "${aws_route_table.private-route-table.id}"
  subnet_id = "${aws_subnet.private-subnet-2.id}"
}

resource "aws_route_table_association" "private-route-table-3-association" {
  route_table_id = "${aws_route_table.private-route-table.id}"
  subnet_id = "${aws_subnet.private-subnet-3.id}"
}

resource "aws_eip" "elastic-ip" {
    domain = "vpc"
    associate_with_private_ip = "10.0.0.5"

    tags = {
        Name = "elastic-ip"
    }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.elastic-ip.id}"
  subnet_id = "${aws_subnet.public-subnet-1.id}"

    tags = {
        Name = "nat-gw"
    }
    depends_on = [aws_eip.elastic-ip]
}

resource "aws_route" "nat-gw-route" {
    route_table_id = "${aws_route_table.private-route-table.id}"
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat-gw.id}"

}

resource "aws_route" "pub-internet-gw-route" {
    route_table_id = "${aws_route_table.public-route-table.id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet-gateway.id}"

}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.dev-vpc.id
}