provider "aws" {
  version = "~> 3.0"
  region  = "eu-west-2"
}

resource "aws_instance" "first-ec2-resource" {
  ami           = "ami-04edc9c2bfcf9a772"
  instance_type = "t2.micro"

  tags = {
    Name = "test-ec2-2"
  }
}

resource "aws_vpc" "test-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "test-vpc-subnet" {
  vpc_id     = aws_vpc.test-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "test-vpc-subnet"
  }
}
