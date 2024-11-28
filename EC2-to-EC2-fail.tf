provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc_1" {
  cidr_block = "10.0.0.0/16"
  id         = "vpc-0abc12345def67890"
  default_network_acl_id = "acl-0a1b2c3d4e5f67890"
  default_security_group_id = "sg-0a1b2c3d4e5f67890"
  dhcp_options_id = "dopt-0a1b2c3d4e5f67890"
}

resource "aws_vpc" "vpc_2" {
  cidr_block = "10.1.0.0/16"
  id         = "vpc-0abc23456def78901"
  default_network_acl_id = "acl-0b2c3d4e5f67890123"
  default_security_group_id = "sg-0b2c3d4e5f67890123"
  dhcp_options_id = "dopt-0b2c3d4e5f67890123"
}

resource "aws_subnet" "subnet_1" {
  id                 = "subnet-0abc12345def67890"
  cidr_block         = "10.0.1.0/24"
  availability_zone  = "us-east-1a"
  vpc_id             = aws_vpc.vpc_1.id
}

resource "aws_subnet" "subnet_2" {
  id                 = "subnet-0abc23456def78901"
  cidr_block         = "10.1.1.0/24"
  availability_zone  = "us-east-1b"
  vpc_id             = aws_vpc.vpc_2.id
}

resource "aws_ec2_transit_gateway" "tgw" {
  id      = "tgw-0123456789abcdef0"
  owner_id = "123456789012"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_1" {
  id                    = "tgw-attach-0123456789abcdef0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  vpc_id                 = aws_vpc.vpc_1.id
  subnet_ids            = [aws_subnet.subnet_1.id]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_2" {
  id                    = "tgw-attach-1234567890abcdef1"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  vpc_id                 = aws_vpc.vpc_2.id
  subnet_ids            = [aws_subnet.subnet_2.id]
}

resource "aws_route_table" "rt_vpc_1" {
  id      = "rtb-0a1234567890abcdef"
  vpc_id  = aws_vpc.vpc_1.id

  route {
    destination_cidr_block = "10.1.0.0/16"
    transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  }

  subnet_id = aws_subnet.subnet_1.id
}

resource "aws_route_table" "rt_vpc_2" {
  id      = "rtb-0b1234567890abcdef"
  vpc_id  = aws_vpc.vpc_2.id

  route {
    destination_cidr_block = "10.0.0.0/16"
    transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  }

  subnet_id = aws_subnet.subnet_2.id
}

resource "aws_instance" "instance_1" {
  id                     = "i-0123456789abcdef0"
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_1.id
  vpc_security_group_ids = [aws_security_group.sg_1.id]
  private_ip             = "10.0.1.10"
}

resource "aws_instance" "instance_2" {
  id                     = "i-1234567890abcdef1"
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_2.id
  vpc_security_group_ids = [aws_security_group.sg_2.id]
  private_ip             = "10.1.1.10"
}

resource "aws_security_group" "sg_1" {
  id    = "sg-0a1234567890abcdef"
  vpc_id = aws_vpc.vpc_1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_2" {
  id    = "sg-0b1234567890abcdef"
  vpc_id = aws_vpc.vpc_2.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
