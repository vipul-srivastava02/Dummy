# 1. Provider Configuration

provider "aws" {
  region = "us-east-1"  # Change to your desired AWS region
}

# 2. VPC, Subnets, and Internet Gateway

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Public Subnet for Web Servers
resource "aws_subnet" "web_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "web-subnet"
  }
}

# Private Subnet for Application Servers
resource "aws_subnet" "app_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "app-subnet"
  }
}

# Private Subnet for DB Servers
resource "aws_subnet" "db_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "db-subnet"
  }
}

# Internet Gateway for Public Subnet (Web Server)
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main-igw"
  }
}


# 3. Security Groups

//Web Server Security Group

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and HTTPS traffic to web servers"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}


// Application Server Security Group

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow traffic from web servers and access to db servers"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.web_subnet.cidr_block]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.web_subnet.cidr_block]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.db_subnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


// Database Server Security Group

resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow traffic from app servers only"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.app_subnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. EC2 Instances for Web, Application, and DB Servers

// Web Server (Public Subnet)
resource "aws_instance" "web" {
  ami             = "ami-0c55b159cbfafe1f0"  # Replace with the latest Amazon Linux 2 AMI
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.web_subnet.id
  security_groups = [aws_security_group.web_sg.name]
  key_name        = "your-key-name"  # Provide your SSH key name
  
  tags = {
    Name = "web-server"
  }

  associate_public_ip_address = true
}

// Application Server (Private Subnet)

resource "aws_instance" "app" {
  ami             = "ami-0c55b159cbfafe1f0"  # Replace with the latest Amazon Linux 2 AMI
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.app_subnet.id
  security_groups = [aws_security_group.app_sg.name]
  key_name        = "your-key-name"  # Provide your SSH key name
  
  tags = {
    Name = "app-server"
  }
}

// Database Server (Private Subnet)

resource "aws_instance" "db" {
  ami             = "ami-0c55b159cbfafe1f0"  # Replace with the latest Amazon Linux 2 AMI
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.db_subnet.id
  security_groups = [aws_security_group.db_sg.name]
  key_name        = "your-key-name"  # Provide your SSH key name
  
  tags = {
    Name = "db-server"
  }
}




