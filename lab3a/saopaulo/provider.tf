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

# Alias: This is strictly for the TGW Peering Accepter 
# to talk to the Tokyo Hub
provider "aws" {
  alias  = "tokyo_hub"
  region = "ap-northeast-1"
}