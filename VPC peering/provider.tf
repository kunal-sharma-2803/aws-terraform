provider "aws" {
  region = var.primary_region
  alias = "primary-region"
}

provider "aws" {
  region = var.secondary_region
  alias = "secondary-region"
}

