terraform {
  backend "s3" {
    bucket = "tf-state-gaspar"
    key = "tf-state-gaspar/tfstate"
    region = "eu-north-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "eu-north-1"
  default_tags {
    tags = var.tags
  }
}
