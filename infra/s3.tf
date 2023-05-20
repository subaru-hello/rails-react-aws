
resource "aws_s3_bucket" "bucket" {
  bucket = "subaru-blog-web"
  force_destroy = true 

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = {
            "AWS": [ 
                "arn:aws:iam::061293269148:user/NestNext", 
                "${aws_cloudfront_origin_access_identity.oai.iam_arn}"
              ]
            },
        Action    = ["s3:GetObject","s3:PutObject"]
        Resource  = ["arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"]
      },
    ]
  })
}
