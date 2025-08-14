variable "region" {
  type    = string
  default = "us-east-1"
}

variable "s3_bucket_name" {
  type        = string
  description = "Name for the S3 bucket to hold Terraform state. Must be globally unique."
  default     = "tf-state-eks-unique-12345" # replace with your unique name
}

variable "dynamodb_table_name" {
  type    = string
  default = "tf-state-lock-table"
}
