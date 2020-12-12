provider aws {
    region = "us-east-1"
}

resource "aws_vpc" "main" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        "Name" = "VPC7Main"
    }
}

resource "aws_subnet" "subnet1a" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.0.0/24"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "Main1Subnet"
    }
}

resource "aws_subnet" "subnet1b" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-east-1b"
    map_public_ip_on_launch = true

    tags = {
        Name = "Main2Subnet"
    }
}

resource "aws_internet_gateway" "gw7" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "InternetGateway7"
    }
}

resource "aws_route_table" "rt7" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw7.id
    }

    tags = {
        Name = "RouteTable7"
    }
}

resource "aws_route_table_association" "sub1a" {
    subnet_id      = aws_subnet.subnet1a.id
    route_table_id = aws_route_table.rt7.id
}

resource "aws_route_table_association" "sub1b" {
    subnet_id      = aws_subnet.subnet1b.id
    route_table_id = aws_route_table.rt7.id
}

resource "aws_network_acl" "acl" {
    vpc_id = aws_vpc.main.id

    ingress {
        protocol   = -1
        rule_no    = 100
        action     = "deny"
        cidr_block = "50.31.252.0/24"
        from_port  = 0
        to_port    = 0
    }
}

resource "aws_security_group" "sg" {
    name   = "Lab7_RDS_SG"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Lab7RDSSG"
    }
}

resource "aws_db_subnet_group" "db_sg" {
    name       = "subnet_group"
    subnet_ids = [aws_subnet.subnet1a.id, aws_subnet.subnet1b.id]

    tags = {
        Name = "DBSubnetGroup7"
    }
}

resource "aws_db_instance" "rds_db" {
    allocated_storage      = 20
    storage_type           = "gp2"
    engine                 = "mysql"
    engine_version         = "5.7"
    instance_class         = "db.t2.micro"
    name                   = "dbtest"
    username               = "testuser"
    password               = "Lgfd!53Kjst34"
    parameter_group_name   = "default.mysql5.7"
    vpc_security_group_ids = [aws_security_group.sg.id]
    db_subnet_group_name   = aws_db_subnet_group.db_sg.id
    publicly_accessible    = true
    skip_final_snapshot    = true
}
