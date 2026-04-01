resource "aws_s3_bucket" "upload-bucket" {

bucket = var.upload-bucket

}

resource "aws_s3_bucket" "clean-bucket" {

bucket = var.clean-bucket

}

resource "aws_s3_bucket" "quarantine-bucket" {

bucket = var.quarantine-bucket

}

resource "aws_s3_bucket" "scan-results-bucket" {

bucket = var.scan-results-bucket

}

resource "aws_s3_bucket" "athena-results-bucket" {

bucket = var.athena-results-bucket

}

