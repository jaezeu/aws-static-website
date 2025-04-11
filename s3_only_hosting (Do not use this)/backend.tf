terraform {
  backend "s3" {
    bucket = "sctp-ce8-tfstate"
    key = "jaz-s3-static.tfstate"
    region = "ap-southeast-1"
  }
}