variable "primary_region" {
  description = "region to deploy resources"
  type = string
  default = "ap-south-1"
}

variable "secondary_region" {
  description = "region to deploy resources"
  type = string
  default = "ap-south-2"
}

variable "primary_vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "secondary_vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "primary_vpc_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "secondary_vpc_subnet_cidr" {
  default = "10.1.1.0/24"
}

variable "instance_type" {
  default = "t3.micro"
}

