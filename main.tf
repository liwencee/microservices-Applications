# terraform {
#   required_version = ">= 1.3.0"

#   backend "s3" {
#     bucket         = "your-unique-tfstate-bucket-name" # change to your bucket
#     key            = "eks/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }

# provider "aws" {
#   region = var.region
# }

# module "eks" {
#   source              = "./modules/eks"
#   cluster_name        = var.cluster_name
#   region              = var.region
#   vpc_cidr            = var.vpc_cidr
#   public_subnet_cidrs = var.public_subnet_cidrs
#   private_subnet_cidrs = var.private_subnet_cidrs
# }
