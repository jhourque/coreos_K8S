region = "eu-west-2"
region_backend = "eu-central-1"

cidr_block = "10.40.0.0/16"

vpc_name = "COREOS K8S"

domain = "coreos.k8s"

key_name = "aws-k8s"
state_bucket = "coreosk8s-tfstate"
repo_state_key = "repo.tfstate"
vpc_state_key = "vpc.tfstate"
dns_alias = "k8s"

node-count = "4"
kubelet_version = "v1.10.0_coreos.0"

