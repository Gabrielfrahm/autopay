terraform {
  required_version = ">=1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = ">=2.1.0"
  }
  backend "s3" {
    bucket = "autopay-tfstate"
    key    = "terraform/ecs.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region     = var.aws_region
}