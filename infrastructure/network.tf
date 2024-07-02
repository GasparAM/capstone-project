resource "aws_vpc" "tf" {
  cidr_block       = var.cidr_block_vpc
  instance_tenancy = "default"
}

resource "aws_subnet" "private" {
  for_each          = local.subnets_private
  vpc_id            = aws_vpc.tf.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
}


resource "aws_subnet" "public" {
  for_each                = local.subnets_public
  vpc_id                  = aws_vpc.tf.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "tf" {
  vpc_id = aws_vpc.tf.id
}

resource "aws_route_table" "tf" {
  vpc_id = aws_vpc.tf.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf.id
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.tf.id
}

resource "aws_security_group" "tf" {
  vpc_id = aws_vpc.tf.id

  dynamic ingress {
    for_each = var.sg_ingress != null ? var.sg_ingress : {}
    iterator = ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = var.ingress_ips
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress != null ? var.sg_egress : {}
    iterator = egress
    content {
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    }
  }
}