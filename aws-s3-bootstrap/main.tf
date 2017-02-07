provider "aws" {
    region = "eu-west-2"
}

resource "aws_s3_bucket" "bootstrap" {
    # s3 namespace is global, use a uuid to be pretty sure it's unique
    bucket = "bootstrap-${uuid()}"

    versioning {
        enabled = true
    }

    lifecycle {
        # uuid() will regenerate each time the state is evaluated
        ignore_changes = ["bucket"]
    }
}

output "bucket" {
    value = "${aws_s3_bucket.bootstrap.bucket}"
}
