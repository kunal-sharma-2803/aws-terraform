variable "region" {
  description = "Region to deploy resources"
  type = string
  default = "ap-south-1"
}

variable "bucket_name" {
  description = "bucket names in list variable type"
  type = list(string)
  default = [ "cwear-image-storage-bucket1", "cwear-image-storage-bucket2" ]
}

variable "bucket_name_set" {
  description = "bucket name in set variable type"
  type = set(string)
  default = [ "cwear-image-storage-bucket3", "cwear-image-storage-bucket4" ]
}