variable "region" {
  type = "string"
}

variable "region_backend" {
  type = "string"
}

variable "cidr_block" {
  type = "string"
}

variable "state_bucket" {
  type = "string"
}

variable "vpc_state_key" {
  type = "string"
}

variable coreos-name-master {
  type    = "string"
  default = "coreos-master"
}

variable coreos-name-node {
  type    = "string"
  default = "coreos-node"
}

variable node-count {
  type    = "string"
  default = "4"
}

variable kubelet_version {
  type    = "string"
  default = "v1.10.0_coreos.0"
}

provider "aws" {
  region = "${var.region}"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.state_bucket}"
    key    = "${var.vpc_state_key}"
    region = "${var.region_backend}"
  }
}

data "aws_ami" "coreos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CoreOS-stable-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["595879546273"]
}
