
module "eks_cluster" {
  source             = "./modules/eks"
  cluster_name       = var.cluster_name
  region             = var.region
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  node_instance_type = var.node_instance_type
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
}
