variable "region" {
  type    = string
  default = "us-west-1"
}

variable "s3_bucket_name" {
  type        = string
  description = "Name for the S3 bucket to hold Terraform state. Must be globally unique."
  default     = "lekandevops-tfstate-prod-20250814" 
}

variable "dynamodb_table_name" {
  type    = string
  default = "lekandevops-tfstate-prod-20250814" 
}
