provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "gazidizdaroglu-terraform-states"
    key    = "infrastructure.tfstate"
    region = "eu-central-1"
  }
}

