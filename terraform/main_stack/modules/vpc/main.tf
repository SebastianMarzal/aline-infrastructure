data "aws_availability_zones" "available" {
  state = "available"
}

#######
# VPC #
#######
resource "aws_vpc" "this" {
  cidr_block       = var.cidr
  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "SM_VPC"
  }
}

###########
# Subnets #
###########
resource "aws_subnet" "public" {
  count = length(data.aws_availability_zones.available.names)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, var.newbits, 101 + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name                                        = "SM_Public_Subnet_${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }
}

resource "aws_subnet" "private" {
  count = length(data.aws_availability_zones.available.names)

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, var.newbits, 1 + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                        = "SM_Private_Subnet_${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
}

############
# Gateways #
############
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "SM_IGW"
  }
}

resource "aws_eip" "nat" {
  count = length(data.aws_availability_zones.available.names)

  vpc = true
  tags = {
    Name = "SM_EIP_${count.index + 1}"
  }
}

resource "aws_nat_gateway" "this" {
  count = length(data.aws_availability_zones.available.names)

  allocation_id = element(aws_eip.nat[*].id, count.index)
  subnet_id     = element(aws_subnet.public[*].id, count.index)

  tags = {
    Name = "SM_NAT_${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.this]
}

################
# Route Tables #
################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "SM_Public_Route_Table"
  }
}

resource "aws_route_table" "private" {
  count = length(data.aws_availability_zones.available.names)

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "SM_Private_Route_Table_${count.index + 1}"
  }
}

##########
# Routes #
##########
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "private" {
  count = length(data.aws_availability_zones.available.names)

  route_table_id         = element(aws_route_table.private[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)
}

############################
# Route Table Associations #
############################
resource "aws_route_table_association" "public" {
  count = length(data.aws_availability_zones.available.names)

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(data.aws_availability_zones.available.names)

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, count.index)
}

###################
# Security Groups #
###################
resource "aws_security_group" "this" {
  name   = "SM_Security_Group"
  vpc_id = aws_vpc.this.id

  ingress {
    cidr_blocks = [aws_vpc.this.cidr_block]
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  egress {
    ipv6_cidr_blocks = ["::/0"]
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
  }

  tags = {
    Name = "SM_Security_Group"
  }
}