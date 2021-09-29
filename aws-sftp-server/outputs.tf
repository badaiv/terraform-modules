output "aws_transfer_server_aws_endpoint" {
  value = aws_transfer_server.sftp.endpoint
}

output "aws_transfer_server_endpoint" {
  value = aws_route53_record.sftpserver.fqdn
}