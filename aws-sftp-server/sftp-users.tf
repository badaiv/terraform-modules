module "sftpusers" {
  for_each = var.user_map
  source = "./modules/aws-sftp-user"

  username       = each.key
  sshkey         = each.value
  s3_bucket_arn  = aws_s3_bucket.sftp.arn
  s3_bucket_name = aws_s3_bucket.sftp.id
  sftp_server_id = aws_transfer_server.sftp.id
}