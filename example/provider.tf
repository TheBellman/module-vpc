# --------------------------------------------------------------------------------
# terraform runtime definitions
# --------------------------------------------------------------------------------
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Owner   = "Robert"
      Client  = "Little Dog Digital"
      Project = "VPC Module Test"
    }
  }
}
