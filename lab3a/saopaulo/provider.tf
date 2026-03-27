# /saopaulo/provider.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Default provider: This manages all "liberdade-*" resources
provider "aws" {
  region = "sa-east-1"
}
