# create S3 Bucket
resource "aws_s3_bucket" "test_bucket" {
  bucket = "cwear-image-storage-bucket"

  tags = {
    Name        = "My bucket 2.0"
    Environment = var.environment
  }
}
