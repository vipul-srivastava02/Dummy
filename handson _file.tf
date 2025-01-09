
Provider "aws" {
    region = "us-east-1"
}


resource "aws_vpc" "rtf-vpc" {
    cidr_block = "10.0.0.0/24"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "rtf-vpc"
    }
}


resource "aws_subnet" "web-server-subnet" {
    vpc_id = aws_vpc.rtf_vpc.id
    cidr_block = "10.1.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = web-server-subnet
    }
}

resource "aws_subnet" "ap-server-subnet" {
    vpc_id = aws_vpc.rtf-vpc.id
    cidr_block = "10.2.0.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "app-server-subnet"
    }
}



resource "aws_internet_gateway" "rtf-igw" {
    vpc_id = aws_vpc.rtf-vpc.id
    tags = {
        Name = "rtf-igw"
    }
}


resource "aws_security_group" "web-server-sg" {
    Name = "web-server-sg"
    Descripition = " Allow HTTP and HTTPS traffic"
    vpc_id = aws_vpc.rtf-vpc.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "HTTP"
        cidr_blocks = [0.0.0.0/0]
    } 

    ingress {
        from_port = 443
        to_port = 443
        protocol = "HTTPS"
        cidr_blocks = [0.0.0.0/0]
    }


    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [0.0.0.0/0]
    }
}




resource "aws_security_group" "app-server-sg" {
    Name = "app-server-sg"
    Description = "Allow traffic from Web server to App Server"
    vpc_id = aws_vpc.rtf_vpc.id 

    ingress {
        from_port = 80
        to_port = 80 
        protocol = "HTTP"
        cidr_blocks = [aws_subnet.web-server-subnet.cidr_block]
    
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "HTTPS"
        cidr_blocks = [aws_subnet.web-server-subnet.cidr_block]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [0.0.0.0/0]
    }
}



resourece "aws_instance" "web-server" {
    ami = "ami-1234556789"
    instance_type = "m5.large"
    subnet_id = aws_subnet.web-server-subnet.id 
    security_groups = [aws_subnet.web_sg.name]
    key_name = "web-server-key.pem"

    tags = {
        Name = "web-seever"
    }

}

