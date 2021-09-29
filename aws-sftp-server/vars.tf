variable "sftp_bucket_name" {
  type = string
}

variable "aws_route53_zone_name" {
  type    = string
}

variable "user_map" {
  type = map(string)
}