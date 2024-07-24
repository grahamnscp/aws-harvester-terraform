provider "aws" {
  profile = var.aws_profile
  region  = var.region

  default_tags {
    tags =  merge(var.aws_tags)
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

