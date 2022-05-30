provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}

resource "aws_vpc" "terraformvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "terraformvpc"
  }
}

resource "aws_subnet" "some_public_subnet" {
  vpc_id            = "vpc-082c82a7503d93616"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Some Public Subnet"
  }
}

resource "aws_subnet" "some_private_subnet" {
  vpc_id            = "vpc-082c82a7503d93616"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Some Private Subnet"
  }
}

resource "aws_internet_gateway" "terraform_gateway" {
  vpc_id = "vpc-082c82a7503d93616"

  tags = {
    Name = "terraform gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = "vpc-082c82a7503d93616"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-0d91f0f11eafbf717"
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = "igw-0d91f0f11eafbf717"
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = "subnet-02e70915082c5fad8"
  route_table_id = "rtb-05b8d92bc5b9f5430"
}

resource "aws_security_group" "terraform_security" {
  name   = "security"
  vpc_id = "vpc-082c82a7503d93616"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* declare variables */
variable "my_ami_id" {
  default = "ami-079b5e5b3971bd10d"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "key_name" {
  default = "mykeypair"
}

/* HI IAM RESOURCE SECTION */

resource "aws_instance" "myec2" {
  ami           = var.my_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  count         = 1

  subnet_id              = "subnet-02e70915082c5fad8"
  vpc_security_group_ids = [aws_security_group.terraform_security.id]

  tags = {
    "Name"     = "Terraform_instance"
    Department = "Cloud-Devops"
  }
}