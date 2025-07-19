resource "aws_vpc" "new-vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
      Name = "${var.prefix}-vpc"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "private_subnets" {
  count                   = 2
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.new-vpc.id
  cidr_block              = "10.0.${count.index + 10}.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-private-subnet-${count.index}"
  }
}
resource "aws_internet_gateway" "new-igw" {
  vpc_id = aws_vpc.new-vpc.id
  tags = {
      Name = "${var.prefix}-igw"
  }
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.new-vpc.id

  tags = {
    Name = "${var.prefix}-private-rtb"
  }
}

resource "aws_route_table_association" "private_rtb_association" {
  count          = 2
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rtb.id
}


resource "aws_security_group" "lambda_sg" {
  name        = "${var.prefix}-lambda-sg"
  description = "Security Group for private Lambda"
  vpc_id      = aws_vpc.new-vpc.id

  ingress {
    description = "Allow from NLB"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks = [
        aws_subnet.private_subnets[0].cidr_block,
        aws_subnet.private_subnets[1].cidr_block,
    ] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-lambda-sg"
  }
}