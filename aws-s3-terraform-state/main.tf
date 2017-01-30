provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "xono-terraform-state" {
  bucket = "xono-terraform-state"

  versioning {
    enabled = true
  }
}
