provider "aws" {
    region = "eu-west-2"
}

resource "aws_vpc" "play" {
    cidr_block = "10.30.0.0/16"

    tags {
        Name = "play"
    }
}

resource "aws_subnet" "play_public_a" {
    vpc_id = "${aws_vpc.play.id}"
    cidr_block = "10.30.0.0/25"
    availability_zone = "eu-west-2a"

    tags {
        Name = "play_public_a"
    }
}

#resource "aws_subnet" "play_public_b" {
#    vpc_id = "${aws_vpc.play.id}"
#    cidr_block = "10.30.0.128/25"
#    availability_zone = "eu-west-2b"
#
#    tags {
#        Name = "play_public_b"
#    }
#}

resource "aws_subnet" "play_priv_a" {
    vpc_id = "${aws_vpc.play.id}"
    cidr_block = "10.30.1.0/25"
    availability_zone = "eu-west-2a"

    tags {
        Name = "play_priv_a"
    }
}

#resource "aws_subnet" "play_priv_b" {
#    vpc_id = "${aws_vpc.play.id}"
#    cidr_block = "10.30.1.128/25"
#    availability_zone = "eu-west-2b"
#
#    tags {
#        Name = "play_priv_b"
#    }
#}

resource "aws_internet_gateway" "play" {
    vpc_id = "${aws_vpc.play.id}"

    tags {
        Name = "play"
    }
}

resource "aws_route_table" "play_int" {
    vpc_id = "${aws_vpc.play.id}"

    tags {
        Name = "play_int"
    }
}

resource "aws_route" "play_int" {
    route_table_id = "${aws_route_table.play_int.id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.play.id}"
}

resource "aws_route_table_association" "play_int_a" {
    subnet_id = "${aws_subnet.play_public_a.id}"
    route_table_id = "${aws_route_table.play_int.id}"
}

#resource "aws_route_table_association" "play_int_b" {
#    subnet_id = "${aws_subnet.play_public_b.id}"
#    route_table_id = "${aws_route_table.play_int.id}"
#}

resource "aws_eip" "nat" {
}

resource "aws_nat_gateway" "play" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id = "${aws_subnet.play_public_a.id}"

    depends_on = ["aws_internet_gateway.play"]
}

resource "aws_route_table" "play_nat" {
    vpc_id = "${aws_vpc.play.id}"

    tags {
        Name = "play_nat"
    }
}

resource "aws_route" "play_nat" {
    route_table_id = "${aws_route_table.play_nat.id}"
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.play.id}"
}

resource "aws_route_table_association" "play_nat_a" {
    subnet_id = "${aws_subnet.play_priv_a.id}"
    route_table_id = "${aws_route_table.play_nat.id}"
}

#resource "aws_route_table_association" "play_nat_b" {
#    subnet_id = "${aws_subnet.play_priv_b.id}"
#    route_table_id = "${aws_route_table.play_nat.id}"
#}

resource "aws_security_group" "play_bastion" {
    vpc_id = "${aws_vpc.play.id}"

    tags {
        Name = "play_bastion"
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "play_bastion" {
    # Amazon Linux AMI 2016.09.1 (HVM), SSD Volume Type
    ami = "ami-f1949e95"
    subnet_id = "${aws_subnet.play_public_a.id}"
    security_groups = ["${aws_security_group.play_bastion.id}"]
    instance_type = "t2.micro"
    key_name = "terraform"

    associate_public_ip_address = true

    tags {
        Name = "play_bastion"
    }
}

output "bastion_ip" {
    value = "${aws_instance.play_bastion.public_ip}"
}
