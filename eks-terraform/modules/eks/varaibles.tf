variable "cluster_name" {}
variable "region" {}
variable "vpc_cidr" {}
variable "public_subnet_cidrs" {
  type = list(string)
}
variable "private_subnet_cidrs" {
  type = list(string)
}
variable "node_instance_type" {}
variable "desired_capacity" {}
variable "max_size" {}
variable "min_size" {}
variable "node_group_name" {
  default = "default-node-group"
}