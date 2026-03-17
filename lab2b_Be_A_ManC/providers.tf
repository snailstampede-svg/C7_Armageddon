provider "aws" {
  region = "ap-southeast-1"
}
# The specific provider for the CloudFront certificate
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}