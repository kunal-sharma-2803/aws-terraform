# S3 buckets 
# bucket to upload the images
resource "aws_s3_bucket" "upload_bucket" {
  bucket = var.upload_bucket_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "upload_bucket_sse" {
  bucket = aws_s3_bucket.upload_bucket.id 

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "upload_bucket_pab" {
  bucket = aws_s3_bucket.upload_bucket.id 

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# bucket to store the processed images 
resource "aws_s3_bucket" "processed_bucket" {
  bucket = var.processed_bucket_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "processed_bucket_sse" {
  bucket = aws_s3_bucket.processed_bucket.id 

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "processed_bucket_pab" {
  bucket = aws_s3_bucket.processed_bucket.id 

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


