# ACM証明書の参照
data "aws_acm_certificate" "api_cert" {
  domain      = "api.subaru-blog.tokyo"
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_acm_certificate" "web_cert" {
  domain      = "web.subaru-blog.tokyo"
  statuses    = ["ISSUED"]
  most_recent = true
  provider    = aws.us-east-1
}