terraform {
  backend "s3" {
    # this bucket must exist before using this script
    bucket       = "state-storage-bucket-tdk1128"
    key          = "dev/terraform.state"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}