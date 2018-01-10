terraform {
  backend "s3" {
    bucket = "coreosk8s-tfstate2"
    region = "eu-west-1"
  }
}
