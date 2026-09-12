# create S3 Bucket
resource "aws_s3_bucket" "web_bucket" {
  bucket = var.bucket_name

  tags = var.bucket_tags
}

# make the bucket private
resource "aws_s3_bucket_public_access_block" "web_bucket_block" {
  bucket = aws_s3_bucket.web_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# bucket policy
resource "aws_s3_bucket_policy" "allow_access_from_cf" {
  bucket     = aws_s3_bucket.web_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.web_bucket_block]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.web_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}

# uploading website files to s3 
resource "aws_s3_object" "web_objects" {
  bucket = aws_s3_bucket.web_bucket.id

  for_each = fileset("${path.module}/www", "**/*")
  key      = each.value
  source   = "${path.module}/www/${each.value}"
  etag     = filemd5("${path.module}/www/${each.value}")

  content_type = lookup({
    "html" = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript",
    "json" = "application/json",
    "png"  = "image/png",
    "jpg"  = "image/jpeg",
    "jpeg" = "image/jpeg",
    "gif"  = "image/gif",
    "svg"  = "image/svg+xml",
    "ico"  = "image/x-icon",
    "txt"  = "text/plain"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}

# create cloudfront distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    # the domain name and the bucket name must be equal
    domain_name              = aws_s3_bucket.web_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.web_bucket_oac.id
    origin_id                = local.origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "Dev"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}


# how cloudFront authenticates with s3 bucket
resource "aws_cloudfront_origin_access_control" "web_bucket_oac" {
  name                              = "oac-${var.bucket_name}"
  description                       = "OAC for static website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

