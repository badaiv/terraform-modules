terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  required_version = ">= 1.0.7"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.60.0"
    }
  }
}

resource "aws_transfer_server" "sftp" {
  identity_provider_type = "SERVICE_MANAGED"

  logging_role = aws_iam_role.sftp-logging.arn

  tags = {
    Name      = "sftp-transfer-server"
    Terraform = "true"
  }
}

resource "aws_iam_role" "sftp-logging" {
  name = "sftp-logging-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF

  tags = {
    Name      = "sftp-transfer-logging-role"
    Terraform = "true"
  }
}

resource "aws_iam_role_policy" "sftp-logging" {
  name = "sftp-logging-policy"
  role = aws_iam_role.sftp-logging.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
POLICY

}

resource "aws_s3_bucket" "sftp" {
  bucket = var.sftp_bucket_name

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name      = var.sftp_bucket_name
    Terraform = "true"
  }
}

data "aws_route53_zone" "dns-zone" {
  name = var.aws_route53_zone_name
}

resource "aws_route53_record" "sftpserver" {

  zone_id = data.aws_route53_zone.dns-zone.id
  name    = "sftp.${data.aws_route53_zone.dns-zone.name}"
  type    = "CNAME"
  ttl     = "300"

  records = [aws_transfer_server.sftp.endpoint]
}