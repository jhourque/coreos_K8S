variable "region" {
  type = "string"
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_ecr_repository" "app" {
  name = "k8s/simple-php-app"
}

resource "aws_ecr_repository" "mariadb" {
  name = "k8s/mariadb"
}

output "ecr_app_url" {
  value = "${aws_ecr_repository.app.repository_url}"
}

output "ecr_mariadb_url" {
  value = "${aws_ecr_repository.mariadb.repository_url}"
}
