terraform {
  backend "s3" {
    region  = "us-east-1"
    bucket  = "yefp1-terraform-state"
    key     = "main/terraform.tfstate"
    encrypt = true
    acl     = "private"
  }
}