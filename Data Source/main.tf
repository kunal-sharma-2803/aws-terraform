# VPC data source
data "aws_vpc" "vpc_name" {
  filter {
    name   = "tag:Name"
    values = ["vpc1"]
  }
}

# subnet data source 
data "aws_subnet" "shared" {
  filter {
    name   = "tag:Name"
    values = ["subnet1"]
  }

  vpc_id = data.aws_vpc.vpc_name.id
}

# ami data source 
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
}

resource "aws_instance" "ec2-1" {
   ami = data.aws_ami.ubuntu.id
   instance_type = "t3.micro"
   subnet_id = data.aws_subnet.shared.id
   tags = {
     "name" = "data-source-ec2"
   }
}

