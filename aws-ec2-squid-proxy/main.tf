provider "aws" {
    region = "eu-west-2"
}

# Shared resources

resource "aws_vpc" "play_nat_squid" {
    cidr_block = "10.50.0.0/24"

    tags {
        Name = "play_nat_squid"
    }
}

resource "aws_route_table" "play_nat_squid" {
    vpc_id = "${aws_vpc.play_nat_squid.id}"
    
    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.play_nat_squid_nat_inst.id}"
    }

    tags {
        Name = "play_nat_squid"
    }
}

resource "aws_route_table_association" "play_nat_squid_public_routing" {
    subnet_id = "${aws_subnet.play_nat_squid_public_inst.id}"
    route_table_id = "${aws_route_table.play_nat_squid.id}"
}

resource "aws_route_table_association" "play_nat_squid_priv_routing" {
    subnet_id = "${aws_subnet.play_nat_squid_priv_inst.id}"
    route_table_id = "${aws_route_table.play_nat_squid.id}"
}

# NAT resources

resource "aws_internet_gateway" "play_nat_squid_public_igw" {
    vpc_id = "${aws_vpc.play_nat_squid.id}"
    
    tags {
        Name = "play_nat_squid_igw"
    }
}

resource "aws_route_table" "play_nat_squid_int" {
    vpc_id = "${aws_vpc.play_nat_squid.id}"
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.play_nat_squid_public_igw.id}"
    }

    tags {
        Name = "play_nat_squid_int"
    }
}

resource "aws_route_table_association" "play_nat_squid_int_routing" {
    subnet_id = "${aws_subnet.play_nat_squid_public_nat.id}"
    route_table_id = "${aws_route_table.play_nat_squid_int.id}"
}

resource "aws_subnet" "play_nat_squid_public_nat" {
    vpc_id = "${aws_vpc.play_nat_squid.id}"
    cidr_block = "10.50.0.0/26"

    tags {
        Name = "play_nat_squid_public_nat"
    }
}

resource "aws_security_group" "play_nat_squid_nat_sg" {
    vpc_id = "${aws_vpc.play_nat_squid.id}"

    tags {
        Name = "play_nat_squid_nat_sg"
    }
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["10.50.0.0/24"]
    } 

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["10.50.0.0/24"]
    } 

    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["10.50.0.0/24"]
    } 

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 
}

resource "aws_instance" "play_nat_squid_nat_inst" {
    # amzn-ami-vpc-nat-hvm-2016.09.1.20170119-x86_64-ebs
    ami = "ami-7c959f18"
    subnet_id = "${aws_subnet.play_nat_squid_public_nat.id}"
    security_groups = ["${aws_security_group.play_nat_squid_nat_sg.id}"]
    instance_type = "t2.micro"
    key_name = "terraform"

    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "play_nat_squid_nat_inst"
    }
}

# Public resources

resource "aws_subnet" "play_nat_squid_public_inst" {
    vpc_id = "${aws_vpc.play_nat_squid.id}"
    cidr_block = "10.50.0.64/26"

    tags {
        Name = "play_nat_squid_public_inst"
    }
}

resource "aws_security_group" "play_nat_squid_public_sg" {
    vpc_id = "${aws_vpc.play_nat_squid.id}"

    tags {
        Name = "play_nat_squid_public_sg"
    }
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 
}

resource "aws_instance" "play_nat_squid_public_inst" {
    # Amazon Linux AMI 2016.09.1 (HVM), SSD Volume Type
    ami = "ami-f1949e95"
    subnet_id = "${aws_subnet.play_nat_squid_public_inst.id}"
    security_groups = ["${aws_security_group.play_nat_squid_public_sg.id}"]
    instance_type = "t2.micro"
    key_name = "terraform"
  
    user_data = "${file("bootstrap_webserver.sh")}"

    associate_public_ip_address = true

    tags {
        Name = "play_nat_squid_public_inst"
    }
}

# Private resources

resource "aws_subnet" "play_nat_squid_priv_inst" {
    vpc_id = "${aws_vpc.play_nat_squid.id}"
    cidr_block = "10.50.0.128/26"

    tags {
        Name = "play_nat_squid_priv_inst"
    }
}

resource "aws_security_group" "play_nat_squid_priv_sg" {
    vpc_id = "${aws_vpc.play_nat_squid.id}"
    
    tags {
        Name = "play_nat_squid_priv_sg"
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["10.50.0.0/24"]
    } 

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["10.50.0.0/24"]
    } 

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["10.50.0.0/24"]
    } 

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 
}

resource "aws_instance" "play_nat_squid_priv_inst" {
    # Amazon Linux AMI 2016.09.1 (HVM), SSD Volume Type
    ami = "ami-f1949e95"
    subnet_id = "${aws_subnet.play_nat_squid_priv_inst.id}"
    security_groups = ["${aws_security_group.play_nat_squid_priv_sg.id}"]
    instance_type = "t2.micro"
    key_name = "terraform"

    user_data = "${file("bootstrap_webserver.sh")}"

    tags {
        Name = "play_nat_squid_priv_inst"
    }
}

output "ips" {
  value = <<EOF

play_nat_squid_priv_inst   ${aws_instance.play_nat_squid_priv_inst.private_ip}
play_nat_squid_public_inst ${aws_instance.play_nat_squid_public_inst.private_ip} ${aws_instance.play_nat_squid_public_inst.public_ip}
play_nat_squid_nat_inst    ${aws_instance.play_nat_squid_nat_inst.private_ip} ${aws_instance.play_nat_squid_nat_inst.public_ip}
EOF

}
