
# Route53レコードの作成
resource "aws_route53_record" "api" {
  zone_id = "Z0727498BKC380AYZPMR"
  name    = "api.subaru-blog.tokyo"
  type    = "A"

  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = false
  }

}

resource "aws_route53_record" "web" {
  zone_id = "Z0727498BKC380AYZPMR"
  name    = "web.subaru-blog.tokyo"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}