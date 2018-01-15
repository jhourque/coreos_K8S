terraform {
  backend "s3" {
    bucket = "coreosk8s-tfstate"
    region = "eu-central-1"
  }
}
