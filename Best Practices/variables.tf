variable "environment" {
  description = "The current Environment"
  default = "Dev"
  type = string
}

variable "region" {
  description = "Region to deploy"
  default = "ap-south-1"
  type = string
}