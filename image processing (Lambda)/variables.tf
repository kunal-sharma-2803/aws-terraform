variable "region" {
  default = "ap-south-1"
}

variable "upload_bucket_name" {
  default = "upload-bucket-lambda-tdk1128"
}

variable "processed_bucket_name" {
  default = "processed-bucket-lambda-tdk1128"
}

variable "lambda_func_name" {
  default = "image-processing-func"
}