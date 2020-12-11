provider aws {
    region = "us-east-1"
}

resource "aws_security_group" "SG_MH"{
    name = "ELB_SG"

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
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "ELB_SG"
    }
}

resource "aws_lb" "ELB" {
    name = "ELB"
    load_balancer_type = "application"
    subnets = ["subnet-0e4fd39514f4f5976", "subnet-0bfa7b737c7c2da69"]
    security_groups = [aws_security_group.SG_MH.id]
}

resource "aws_instance" "ec2" {
    ami = "ami-08096263443bb4ad2"
    count = 2
    key_name = "KeyPairLab6"
    security_groups = [aws_security_group.SG_MH.name] 
    instance_type = "t2.micro"
    
    tags = {
        Name = format("Instance-%d", count.index)
    }
}

resource "aws_lb_target_group" "TG_MG" {
    name = "TargetGroup"
    port = 80
    protocol = "HTTP"
    vpc_id = "vpc-06f2f00caf57b3a38"
}

resource "aws_lb_target_group_attachment" "TGA_I_MH" {
    count = length(aws_instance.ec2)
    target_group_arn = aws_lb_target_group.TG_MG.arn
    target_id = aws_instance.ec2[count.index].id
    port = 80
}

resource "aws_lb_listener" "listener" {
    load_balancer_arn = aws_lb.ELB.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.TG_MG.arn
    }
}




















# provider "aws" {
#   region = "us-east-1"
# }

# resource "aws_vpc" "vpc6_mh" {
#     cidr_block       = "10.0.0.0/16"
#     enable_dns_hostnames = true

#     tags = {
#         Name = "My VPC Lab6 MH"
#     }
# }

# resource "aws_subnet" "public_subnet_1_mh" {
#     vpc_id     = aws_vpc.vpc6_mh.id
#     cidr_block = "10.0.0.0/24"
#     availability_zone = "us-east-1a"

#     tags = {
#         Name = "Public Subnet Us-East-1a"
#     }
# }

# resource "aws_subnet" "public_subnet_2_mh" {
#     vpc_id     = aws_vpc.vpc6_mh.id
#     cidr_block = "10.0.1.0/24"
#     availability_zone = "us-east-1b"

#     tags = {
#         Name = "Public Subnet Us-East-1b"
#     }
# }

# resource "aws_internet_gateway" "igw_mh" {
#     vpc_id = aws_vpc.vpc6_mh.id

#     tags = {
#         Name = "Internet Gateway"
#     }
# }

# resource "aws_route_table" "route_table_vpc_mh" {
#     vpc_id = aws_vpc.vpc6_mh.id

#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_internet_gateway.igw_mh.id
#     }

#     tags = {
#         Name = "Public Subnets Route Table for MH VPC"
#     }
# }

# resource "aws_route_table_association" "public_subnet_1_mh" {
#     subnet_id = aws_subnet.public_subnet_1_mh.id
#     route_table_id = aws_route_table.route_table_vpc_mh.id
# }

# resource "aws_route_table_association" "public_subnet_2_mh" {
#     subnet_id = aws_subnet.public_subnet_2_mh.id
#     route_table_id = aws_route_table.route_table_vpc_mh.id
# }

# resource "aws_security_group" "configure_http" {
#     name        = "configure_http"
#     description = "Configure HTTP connection"
#     vpc_id = aws_vpc.vpc6_mh.id

#     ingress {
#         from_port   = 80
#         to_port     = 80
#         protocol    = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#     }
    
#     ingress {
#         from_port   = 22
#         to_port     = 22
#         protocol    = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#     }

#     egress {
#         from_port   = 0
#         to_port     = 0
#         protocol    = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#     }

#     tags = {
#         Name = "Allow HTTP"
#     }
# }

# resource "aws_lb" "LB_MH" {
#     name = "ELB_MH"
#     internal = false
#     load_balancer_type = "application"
#     security_groups = [aws_security_group.configure_http.id]
#     subnets = [
#         aws_subnet.public_subnet_1_mh.id,
#         aws_subnet.public_subnet_1_mh.id
#     ]
# }

# resource "aws_launch_configuration" "ec2_instance" {
#     image_id = "ami-066ef6d29e51b5811"
#     instance_type = "t2.micro"
#     key_name = "KeyPairLab6"

#     security_groups = [ aws_security_group.configure_http.id ]
#     associate_public_ip_address = true

#     user_data = << EOF
#         #!/bin/bash
#         sudo yum update -y
#         sudo yum -y install httpd
#         sudo systemctl start httpd
#         sudo systemctl enable httpdn
#         sudo usermod -a -G apache ec2-user
#         sudo chown -R ec2-user:apache /var/www
#         sudo chmod 2775 /var/www
#         find /var/www -type d -exec sudo chmod 2775 {} +
#         find /var/www -type f -exec sudo chmod 0664 {} +
#         echo "<h1>Instance #1. Question here.</h1>" > /var/www/html/index.html
#     EOF
# }
