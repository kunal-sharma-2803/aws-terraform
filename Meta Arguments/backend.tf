terraform {
  backend "s3" {
    # this bucket must exist before using this script
    bucket       = "cwear-state-storage-bucket"
    key          = "dev/terraform.state"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
