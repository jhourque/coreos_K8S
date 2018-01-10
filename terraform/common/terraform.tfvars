region = "eu-west-2"
region_backend = "eu-west-1"

cidr_block = "10.40.0.0/16"

vpc_name = "DEMO K8S"

domain = "demo.k8s"

key_name = "aws-k8s"
state_bucket = "coreosk8s-tfstate2"
repo_state_key = "repo.tfstate"
vpc_state_key = "vpc.tfstate"
dns_alias = "k8s"
