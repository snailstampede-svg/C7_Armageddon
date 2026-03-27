# Tokyo looks into Sao Paulo's bucket to see what happened there
data "terraform_remote_state" "saopaulo" {
  backend = "s3"
  config = {
    bucket = "mytf-storage-files-2-28-2026"
    key    = "lab/my-state-files/saopaulo.tfstate" # Adjust to your SP key
    region = "us-east-1"
  }
}