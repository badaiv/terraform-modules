resource "aws_iam_role" "sftp" {
  name = "sftp-${var.username}-user-role"

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
    Name      = "sftp-${var.username}-user-role"
    Terraform = "true"
  }
}

resource "aws_iam_role_policy" "sftp" {
  name = "sftp-${var.username}-user-policy"
  role = aws_iam_role.sftp.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowListingFolder",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "${var.s3_bucket_arn}",
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "${var.username}/*",
                        "${var.username}"
                    ]
                }
            }
        },
        {
            "Sid": "AllowReadWriteToObject",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ],
            "Resource": "${var.s3_bucket_arn}/${var.username}*"
        }
    ]
}
POLICY
}

resource "aws_transfer_user" "user" {
  server_id      = var.sftp_server_id
  user_name      = var.username
  role           = aws_iam_role.sftp.arn
  home_directory = "/${var.s3_bucket_name}/${var.username}"

  tags = {
    Terraform = "true"
  }
}

resource "aws_transfer_ssh_key" "user" {
  server_id = var.sftp_server_id
  user_name = aws_transfer_user.user.user_name
  body      = var.sshkey

}