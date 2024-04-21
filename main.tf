# AWS PROVIDER
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["C:/Users/tomas/.aws/credentials.txt"]
}

# SET UP VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my_vpc"
  }
}

# CREATE SUBNETS
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.101.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.102.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private_subnet"
  }
}

# CREATE INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    name = "my_igw"
  }
}

# CREATE ROUTE TABLES
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# ASSOCIATE ROUTE TABLE WITH PUBLIC SUBNET
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# CONFIGURE SECURITY GROUPS
resource "aws_security_group" "server_sg" {
  name        = "server_security"
  description = "allow ssh, http traffic"
  vpc_id      = aws_vpc.my_vpc.id


  ingress {
    description = "HTTP Backend"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP Frontend"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
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

  tags = {
    Name = "sg"
  }
}


# DEPLOY EC2 INSTANCES
resource "aws_instance" "server" {
  ami                         = "ami-080e1f13689e07408"
  instance_type               = "t2.micro"
  key_name                    = "vockey"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.server_sg.id]
  user_data_replace_on_change = true
  tags = {
    Name = "Server"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "mkdir /home/ubuntu/app",
      "mkdir /tmp/app",
      "mkdir /tmp/front",
      "sudo apt-get install -y python3 python3-pip",
      "sudo pip3 install Flask Flask-CORS Flask-Session flask-socketio eventlet",
      "curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash - ",
      "sudo apt-get install -y nodejs",
      "sudo apt-get install -y nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("labsuser.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "backend/src"
    destination = "/tmp/app"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("labsuser.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "frontend/src/"
    destination = "/tmp/front"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("labsuser.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/app/ /home/ubuntu/",
      "cd /home/ubuntu/app/src/ && sudo chmod +x app.py && sudo nohup python3 app.py > /dev/null 2>&1 &",
      "sudo mv /tmp/front/* /var/www/html/",
      "cd /var/www/html/ && sudo sed -i 's|const SERVER_URL = .*|const SERVER_URL = \"http://${self.public_ip}:5000\";|' game.js",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("labsuser.pem")
      host        = self.public_ip
    }
  }
}

# OUTPUT IP ADDRESSES
output "server_public_ip" {
  value = aws_instance.server.public_ip
}

