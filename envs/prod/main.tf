# Use modules: vpc and eks

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr              = "10.0.0.0/16"
  public_subnet_cidrs   = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  azs                   = [] # default: first 3 AZs
  tags = {
    Environment = "prod"
    Project     = "eks"
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name     = var.cluster_name
  region           = var.region
  vpc_id           = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  eks_version      = "1.28"
  node_instance_types = ["t3.medium"]
  node_min_size       = 1
  node_desired_size   = 1
  node_max_size       = 1
  tags = {
    Environment = "prod"
    Project     = "eks"
  }
}
