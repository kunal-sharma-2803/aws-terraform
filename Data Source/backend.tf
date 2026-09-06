terraform {
  backend "s3" {
    # this bucket must exist before using this script
    bucket       = "demo-state-storage-bucket-1128"
    key          = "dev/terraform.state"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}