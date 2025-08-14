# microservices-Applications
Deploying a microservices from docker image from DockerHub
# Terraform EKS (us-west-1) — reusable modules + S3/DynamoDB backend bootstrap

## Overview
This repo contains:
- `bootstrap/` — Terraform to create the S3 bucket and DynamoDB table used for remote state.
- `modules/vpc` — reusable VPC module (3 AZs, public/private subnets, NATs).
- `modules/eks` — reusable EKS module (cluster + managed node group).
- `envs/prod` — production environment wiring modules together and `init-backend.sh`.

## Recommended workflow

1. Fill `bootstrap/variables.tf` with a globally-unique S3 bucket name (or pass via `-var`).
2. Create the backend resources:


### How to use the backend script ####

cd bootstrap
terraform init
terraform apply

Note outputs: `s3_bucket` and `dynamodb_table`.

3. Initialize the main environment backend:


cd ../envs/prod
./init-backend.sh -b lekandevops-tfstate-prod-20250814 -t lekandevops-tfstate-prod-20250814 -r us-west-1


Or:


terraform init
-backend-config="bucket=<bucket>"
-backend-config="key=envs/prod/terraform.tfstate"
-backend-config="region=us-west-1"
-backend-config="dynamodb_table=<table>"


4. Apply the prod environment:


terraform apply -var="cluster_name=prod-eks" -var="region=us-west-1"


5. Get kubeconfig:


aws eks update-kubeconfig --region us-west-1 --name prod-eks


## Notes & caveats
- Terraform backend cannot be configured dynamically via variables inside the backend block. That's why we create the bucket/table first (bootstrap), then pass the values to `terraform init -backend-config=...`.
- The modules are intentionally opinionated but simple. Adjust subnet CIDRs, instance types, autoscaling configs, node AMIs, and IAM policies as required for your org.
- Consider enabling encryption with a CMK for the S3 bucket, and stricter IAM for production.
- For node groups using custom launch templates (GPU/taints/labels), extend `modules/eks` accordingly.





terraform-eks-repo/
├─ .gitignore
├─ create-backend.sh
├─ providers.tf
├─ variables.tf
├─ main.tf
├─ outputs.tf
├─ modules/
│  ├─ vpc/
│  │  ├─ main.tf
│  │  ├─ variables.tf
│  │  └─ outputs.tf
│  └─ eks/
│     ├─ main.tf
│     ├─ variables.tf
│     └─ outputs.tf
└─ envs/
   └─ prod/
      └─ terraform.tfvars    # example values (optional)

