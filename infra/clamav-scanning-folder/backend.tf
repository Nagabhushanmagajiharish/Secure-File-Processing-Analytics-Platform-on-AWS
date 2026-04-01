terraform {
  backend "s3" {
    bucket  = "secure-file-processing-backend-bucket"
    key     = "infra/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}