provider "aws" {
  region  = "eu-west-2"
  version = "~> 3.2.0"
}

# 1. Create VPC.
resource "aws_vpc" "project_2_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Project 2 VPC"
  }
}

# 2. Create IGW.
resource "aws_internet_gateway" "project_2_igw" {
  vpc_id = aws_vpc.project_2_vpc.id

  tags = {
    Name = "Project 2 IGW"
  }
}

# 3. Create Custom Route Table.
resource "aws_route_table" "project_2_route_table" {
  vpc_id = aws_vpc.project_2_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project_2_igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.project_2_igw.id
  }

  tags = {
    Name = "Project 2 Route Table"
  }
}

# 4. Create a Subnet.
resource "aws_subnet" "project_2_subnet" {
  vpc_id     = aws_vpc.project_2_vpc.id
  cidr_block = "10.0.1.0/24"

  # This will be random if not specified, and your instance may not match the subnet.
  availability_zone = "eu-west-2c"

  tags = {
    Name = "Project 2 Subnet"
  }
}

# 5. Associate the Subnet with the Route Table.
resource "aws_route_table_association" "project_2_route_table_association" {
  subnet_id      = aws_subnet.project_2_subnet.id
  route_table_id = aws_route_table.project_2_route_table.id
}

# 6. Create a Security Group and allow ports 22, 80, 443.
resource "aws_security_group" "project_2_security_group_allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web Traffic"
  vpc_id      = aws_vpc.project_2_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow Web Traffic"
  }
}

# 7. Create a Network Interface with an IP in the Subnet that was created in step 4.
resource "aws_network_interface" "project_2_network_interface" {
  subnet_id       = aws_subnet.project_2_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.project_2_security_group_allow_web.id]

  # Can specify it here, or instead choose the NIC when creating the instance.
  #   attachment {
  #     instance     = "value"
  #     device_index = 1
  #   }
}

# 8. Assign an elastic IP to the Network Interface created in step 7.
resource "aws_eip" "project_2_eip" {
  vpc                       = true
  network_interface         = aws_network_interface.project_2_network_interface.id
  associate_with_private_ip = "10.0.1.50"

  # The IGW has to exist prior to creation, so you need to use depends_on.
  depends_on = [aws_internet_gateway.project_2_igw]
}

output "server_public_ip" {
  value = aws_eip.project_2_eip.public_ip
}

# 9. Create an Ubuntu server and install/enable apache2.
resource "aws_instance" "project_2_web_server" {
  ami           = "ami-04edc9c2bfcf9a772"
  instance_type = "t2.micro"

  # This will be random if not specified, and your instance may not match the subnet.
  availability_zone = "eu-west-2c"
  key_name          = "terraform-test-keypair"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.project_2_network_interface.id
  }

  user_data = <<-EOF
    #!/usr/bin/env bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo bash -c 'echo your very first web server > '/var/www/html/index.html'
  EOF

  tags = {
    Name = "Project 2 Web Server"
  }
}
