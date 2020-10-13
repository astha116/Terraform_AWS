resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"


  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.r.id
}

resource "aws_security_group" "ssh_allowed" {
  name        = "ssh-allowed"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ssh-allowed"
  }
}

resource "aws_instance" "web1" {
  ami           = lookup(var.AMI, var.AWS_REGION)
  instance_type = "t2.micro"
  # VPC
  subnet_id = aws_subnet.main.id
  # Security Group
  vpc_security_group_ids = [aws_security_group.ssh_allowed.id]
  # the Public SSH key
  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true
  #   connection {
  #     user        = var.EC2_USER
  #     private_key = file(var.PRIVATE_KEY_PATH)
  #   }
}
resource "aws_key_pair" "key_pair" {
  key_name   = "key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJ0WoMFdl5vUQdZYoXPPZuuC01NJIOAxfHcT68QiSoG5pNByAou79++h31Lp/0tNzQMWW19GUQIY6WA/r8eVyDHgCrqQ3b4PUOINNRBv8zkXCb9hoc393QeMn7PeX86asUSJz8ThNUILSlDW3eszlB86jQK8ebLz6FPGmr1KxzL+Z32pI26+rkQthNFiPS0WX2R3+KhgIRLbN+4qZCR3XMoQ5HcIJETHWhCxWTszPadj2KAjHL/D7uWXYYX6TM9X4RCR3Ukgp7OJtlHConnbg3QEgWKHQ9KmXe47meh3yeFbLMoeI7/8QZLYwjV0fE770Jrp2Yfl1BjECGwChv5otk6Uev/L+BGnTsrdTiApSVmlm+vfN08bzhxShW4FusXTGosB5yHw20hPtpoNX9D4Px0yXHwHvCsDqdPxyeGm83PbdUMlZeVpQ8te01p1tlYJYcurCc7jwMtIL+ic55wT0HWy3H3QP4/d9so6TY4Zdzjgjv6BI9rKqMlECQCp88vE8= ASTHA@LAPTOP-IJ9EI01J"

}
