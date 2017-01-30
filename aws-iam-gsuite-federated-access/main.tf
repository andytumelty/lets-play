provider "aws" {
  region = "eu-west-2"
}

resource "aws_iam_saml_provider" "google" {
  name = "google"
  saml_metadata_document = "${file("SAML.xml")}"
}

resource "aws_iam_role" "gsuite-admin" {
  name = "gsuite-admin"
  assume_role_policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Federated": "arn:aws:iam::472436770688:saml-provider/google"
          },
          "Action": "sts:AssumeRoleWithSAML",
          "Condition": {
            "StringEquals": {
              "SAML:aud":"https://signin.aws.amazon.com/saml"
            }
          }
        }
      ]
    }
EOF
}
