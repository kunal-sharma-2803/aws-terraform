# create S3 Bucket
resource "aws_s3_bucket" "test_bucket" {
  bucket = var.bucket_name

  tags = var.bucket_tags
}