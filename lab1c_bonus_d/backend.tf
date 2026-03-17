terraform {

    backend "s3" {
        bucket = "mytf-storage-files-2-28-2026"
        key = "lab/my-state-files/lab1c-bonus-d/terraform.tfstate"
        region = "us-east-1"
        encrypt = true
      
    }
}