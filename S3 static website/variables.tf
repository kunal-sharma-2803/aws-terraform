variable "bucket_name" {
  description = "bucket for storing static files"
  type = string
}

variable "region" {
  description = "region of bucket and other resources"
  type = string
  default = "ap-south-1"
}

variable "bucket_tags" {
  description = "bucket tags"
  type = map(string)
}