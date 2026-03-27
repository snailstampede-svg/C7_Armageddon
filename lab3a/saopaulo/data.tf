# This lets Sao Paulo "read" the Tokyo state file from S3
data "terraform_remote_state" "tokyo" {
  backend = "s3"

  config = {
    bucket = "mytf-storage-files-2-28-2026"
    key    = "lab/my-state-files/lab3a.tfstate"
    region = "us-east-1"
  }
}