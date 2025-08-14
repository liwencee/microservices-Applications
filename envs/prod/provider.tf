terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # backend is configured via CLI using -backend-config or via a backend.tf file created after bootstrap
}

provider "aws" {
  region = var.region
}
