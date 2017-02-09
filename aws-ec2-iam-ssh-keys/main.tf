provider "aws" {
    region = "eu-west-2"
}

data "terraform_remote_state" "bootstrap" {
    backend = "s3"

    config {
        bucket = "xono-terraform-state"
        key = "aws-bootstrap/terraform.tfstate"
        region = "eu-west-2"
    }
}

data "template_file" "bootstrap" {
    template = "${file("bootstrap.sh")}"
    
    vars {
        bootstrap = "${data.terraform_remote_state.bootstrap.bucket}"
    }
}

resource "aws_iam_role_policy" "play_ssh" {
    name = "play_ssh"
    role = "${aws_iam_role.play_ssh.id}"
    policy = "${file("play_ssh_keys_policy.json")}"
}

resource "aws_iam_role" "play_ssh" {
    name = "play_ssh"
    assume_role_policy = "${file("play_ssh_assume_policy.json")}"
}

resource "aws_iam_instance_profile" "play_ssh" {
        name = "play_ssh"
        roles = ["${aws_iam_role.play_ssh.name}"]
}

resource "aws_s3_bucket_object" "iam_check_keys" {
    bucket = "${data.terraform_remote_state.bootstrap.bucket}"
    key = "aws-ec2-iam-ssh-keys/iam_check_keys.sh"
    source = "iam_check_keys.sh"
    etag = "${md5(file("iam_check_keys.sh"))}"
}

resource "aws_s3_bucket_object" "iam_update_users" {
    bucket = "${data.terraform_remote_state.bootstrap.bucket}"
    key = "aws-ec2-iam-ssh-keys/iam_update_users.sh"
    source = "iam_update_users.sh"
    etag = "${md5(file("iam_update_users.sh"))}"
}

resource "aws_instance" "play_ssh_keys" {
    ami = "ami-f1949e95"
    instance_type = "t2.micro"
    subnet_id = "subnet-9bcb2ae0"
    key_name = "noaccess"
    associate_public_ip_address = true
    iam_instance_profile = "${aws_iam_instance_profile.play_ssh.name}"

    tags {
        Name = "play_ssh_keys"
    }

    user_data = "${data.template_file.bootstrap.rendered}"
}

output "ip" {
    value = "${aws_instance.play_ssh_keys.public_ip}"
}
