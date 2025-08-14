# microservices-Applications
Deploying a microservices from docker image from DockerHub
# Terraform EKS (us-east-1) — reusable modules + S3/DynamoDB backend bootstrap

## Overview
This repo contains:
- `bootstrap/` — Terraform to create the S3 bucket and DynamoDB table used for remote state.
- `modules/vpc` — reusable VPC module (3 AZs, public/private subnets, NATs).
- `modules/eks` — reusable EKS module (cluster + managed node group).
- `envs/prod` — production environment wiring modules together and `init-backend.sh`.

## Recommended workflow

1. Fill `bootstrap/variables.tf` with a globally-unique S3 bucket name (or pass via `-var`).
2. Create the backend resources:
