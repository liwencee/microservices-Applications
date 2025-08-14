variable "region" {
  type    = string
  default = "us-west-1"
}

variable "cluster_name" {
  type    = string
  default = "prod-eks-cluster"
}

variable "s3_bucket" {
  type    = string
  default = "" # set via -backend-config or create a backend.tf with the real name
}

variable "dynamodb_table" {
  type    = string
  default = ""
}
