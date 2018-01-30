#Kubernetes cluster deployed in AWS with terraform

## Setup
### Install terraform
```
wget https://releases.hashicorp.com/terraform/0.11.2/terraform_0.11.2_linux_amd64.zip -O terraform.zip
unzip terraform.zip
chmod +x terraform
sudo install terraform /usr/bin
```

### Install Config Transpiler (ct)
```
wget https://github.com/coreos/container-linux-config-transpiler/releases/download/v0.6.0/ct-v0.6.0-x86_64-unknown-linux-gnu -O ct
chmod +x ct
sudo install  ct /usr/bin
```

### Set AWS config
Create ssh keypair
```
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa.k8s
```

Set AWS env
```
export AWS_ACCESS_KEY_ID="<your access key>"
export AWS_SECRET_ACCESS_KEY="<your secret key>"
export AWS_DEFAULT_REGION="<region>"
```

Set Terraform config
```
Edit "terraform/common/terraform.tfvars"
Update for your config:
    region = "eu-central-1"
    region_backend = "eu-central-1"
    cidr_block = "10.40.0.0/16"

Edit "terraform/common/backend.tf"
Update for your config:
    bucket = "coreosk8s-tfstate"
    region = "eu-central-1"         # = region_backend
```

### Create VPC
In terraform/vpc
```
./init
terraform apply
```

### Setup K8S Cluster
Generate ca and admin keys and update cloud config in terraform/k8s/files/ssl
```
./ca_generator.sh
./admin_generator.sh
./inject_ca.sh
```
Generate ignition files in terraform/k8s/files
```
./gen_ign.sh
```

### Create K8S Cluster
In terraform/k8s
```
./init
terraform apply
```

### Test it from bastion
Copy script and admin key to bastion (in terraform/k8s/files):
```
scp -i ~/id_rsa.k8s -r set_kube ssl admin@<bastion IP>
ssh  -i ~/id_rsa.k8s admin@<bastion IP>
./set_kube <coreos_master IP>
kubectl get nodes
```


## TODO:
- Enable RBAC
- Configure multi-Master
