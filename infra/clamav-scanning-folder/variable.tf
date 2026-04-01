variable "upload-bucket" {
  type    = string
  default = "secure-file-processing-upload-061039787667-euw2"
}

variable "clean-bucket" {
  type    = string
  default = "secure-file-processing-clean-061039787667-euw2"
}

variable "quarantine-bucket" {
  type    = string
  default = "secure-file-processing-quarantine-061039787667-euw2"
}

variable "scan-results-bucket" {
  type    = string
  default = "secure-file-processing-scan-results-061039787667-euw2"
}

variable "athena-results-bucket" {
  type    = string
  default = "secure-file-processing-athena-results-061039787667-euw2"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}