terraform {
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# create S3 Bucket
resource "aws_s3_bucket" "test_bucket" {
  bucket = "cwear-image-storage-bucket"

  tags = {
    Name        = "My bucket 2.0"
    Environment = "Dev"
  }
}