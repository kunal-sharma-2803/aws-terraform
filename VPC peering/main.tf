# for primary
# creating primary VPC
resource "aws_vpc" "primary_vpc" {
  cidr_block = var.primary_vpc_cidr
  provider   = aws.primary-region

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "primary-vpc-${var.primary_region}"
  }
}

# subnet for primary VPC
resource "aws_subnet" "primary_vpc_subnet" {
  provider   = aws.primary-region
  vpc_id     = aws_vpc.primary_vpc.id
  cidr_block = var.primary_vpc_subnet_cidr

  availability_zone = data.aws_availability_zones.primary.names[0]

  map_public_ip_on_launch = true

  tags = {
    Name        = "primary-vpc-subnet-${var.primary_region}"
    Environment = "Dev"
  }
}

# internet gateway for primary VPC
resource "aws_internet_gateway" "primary_vpc_igw" {
  provider = aws.primary-region
  vpc_id   = aws_vpc.primary_vpc.id

  tags = {
    Name        = "primary-vpc-igw-${var.primary_region}"
    Environment = "Dev"
  }
}

# route table for primary VPC
resource "aws_route_table" "primary_vpc_rt" {
  provider = aws.primary-region
  vpc_id   = aws_vpc.primary_vpc.id

  route {
    # for this destination
    cidr_block = "0.0.0.0/0"

    # send traffic through here 
    gateway_id = aws_internet_gateway.primary_vpc_igw.id
  }

  tags = {
    Name        = "primary-vpc-rt-${var.primary_region}"
    Environment = "Dev"
  }
}

# associate with primary VPC subnet
resource "aws_route_table_association" "primary_vpc_rt_association" {
  provider       = aws.primary-region
  subnet_id      = aws_subnet.primary_vpc_subnet.id
  route_table_id = aws_route_table.primary_vpc_rt.id
}

# creating VPC connection 
resource "aws_vpc_peering_connection" "primary_to_secondary" {
  provider    = aws.primary-region
  vpc_id      = aws_vpc.primary_vpc.id
  peer_vpc_id = aws_vpc.secondary_vpc.id
  peer_region = var.secondary_region

  auto_accept = false

  tags = {
    Name        = "primary-to-secondary-peering"
    Environment = "Dev"
    Side        = "Requester"
    # this side is for the connection setup process only, dont think in terms of sender and reciever 
  }

}

# add route to primary rt 
resource "aws_route" "primary_to_secondary_vpc_rt" {
  provider                  = aws.primary-region
  route_table_id            = aws_route_table.primary_vpc_rt.id
  destination_cidr_block    = var.secondary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [aws_vpc_peering_connection_accepter.secondary_to_primary]
}




# for secondary
# creating secondary VPC
resource "aws_vpc" "secondary_vpc" {
  cidr_block = var.secondary_vpc_cidr
  provider   = aws.secondary-region

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "secondary-vpc-${var.secondary_region}"
  }
}

# subnet for secondary VPC
resource "aws_subnet" "secondary_vpc_subnet" {
  provider   = aws.secondary-region
  vpc_id     = aws_vpc.secondary_vpc.id
  cidr_block = var.secondary_vpc_subnet_cidr

  availability_zone = data.aws_availability_zones.secondary.names[0]

  map_public_ip_on_launch = true

  tags = {
    Name        = "secondary-vpc-subnet-${var.secondary_region}"
    Environment = "Dev"
  }
}

# internet gateway for secondary VPC
resource "aws_internet_gateway" "secondary_vpc_igw" {
  provider = aws.secondary-region
  vpc_id   = aws_vpc.secondary_vpc.id

  tags = {
    Name        = "secondary-vpc-igw-${var.secondary_region}"
    Environment = "Dev"
  }
}

# route table for secondary VPC
resource "aws_route_table" "secondary_vpc_rt" {
  provider = aws.secondary-region
  vpc_id   = aws_vpc.secondary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary_vpc_igw.id
  }

  tags = {
    Name        = "secondary-vpc-rt-${var.secondary_region}"
    Environment = "Dev"
  }
}

# associate with secondary VPC subnet
resource "aws_route_table_association" "secondary_vpc_rt_association" {
  provider       = aws.secondary-region
  subnet_id      = aws_subnet.secondary_vpc_subnet.id
  route_table_id = aws_route_table.secondary_vpc_rt.id
}

# creating VPC connection 
resource "aws_vpc_peering_connection_accepter" "secondary_to_primary" {
  provider                  = aws.secondary-region
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
  auto_accept               = true

  tags = {
    Name        = "secondary-to-primary-peering"
    Environment = "Dev"
    Side        = "Accepter"
  }
}

# add route to secondary rt 
resource "aws_route" "secondary_to_primary_vpc_rt" {
  provider                  = aws.secondary-region
  route_table_id            = aws_route_table.secondary_vpc_rt.id
  destination_cidr_block    = var.primary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [aws_vpc_peering_connection_accepter.secondary_to_primary]
}

# EC2 setup
# Security Group for Primary VPC EC2 instance
resource "aws_security_group" "primary_sg" {
  provider    = aws.primary-region
  name        = "primary-vpc-sg"
  description = "Security group for Primary VPC instance"
  vpc_id      = aws_vpc.primary_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from Secondary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.secondary_vpc_cidr]
  }

  ingress {
    description = "All traffic from Secondary VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.secondary_vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Primary-VPC-SG"
    Environment = "Demo"
  }
}

# Security Group for Secondary VPC EC2 instance
resource "aws_security_group" "secondary_sg" {
  provider    = aws.secondary-region
  name        = "secondary-vpc-sg"
  description = "Security group for Secondary VPC instance"
  vpc_id      = aws_vpc.secondary_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from Primary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.primary_vpc_cidr]
  }

  ingress {
    description = "All traffic from Primary VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.primary_vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Secondary-VPC-SG"
    Environment = "Demo"
  }
}

# EC2 Instance in Primary VPC
resource "aws_instance" "primary_instance" {
  provider               = aws.primary-region
  ami                    = data.aws_ami.primary_ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.primary_vpc_subnet.id
  vpc_security_group_ids = [aws_security_group.primary_sg.id]
  key_name               = "vpc-peering"

  # script that runs when instance starts 
  user_data = local.primary_user_data

  tags = {
    Name        = "Primary-VPC-Instance"
    Environment = "Dev"
    Region      = var.primary_region
  }

  depends_on = [aws_vpc_peering_connection_accepter.secondary_to_primary ]
}

# EC2 Instance in Secondary VPC
resource "aws_instance" "secondary_instance" {
  provider               = aws.secondary-region
  ami                    = data.aws_ami.secondary_ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.secondary_vpc_subnet.id 
  vpc_security_group_ids = [aws_security_group.secondary_sg.id]
  key_name               = "vpc-peering"

  user_data = local.secondary_user_data

  tags = {
    Name        = "Secondary-VPC-Instance"
    Environment = "Dev"
    Region      = var.secondary_region
  }

  depends_on = [ aws_vpc_peering_connection_accepter.secondary_to_primary ]
}

