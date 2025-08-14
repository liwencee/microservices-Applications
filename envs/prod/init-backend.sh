#!/usr/bin/env bash
# Usage:
# ./init-backend.sh -b <bucket> -t <dynamodb_table> -r <region>
set -e

while getopts b:t:r: flag; do
  case "${flag}" in
    b) BUCKET=${OPTARG};;
    t) TABLE=${OPTARG};;
    r) REGION=${OPTARG};;
  esac
done

if [ -z "$BUCKET" ] || [ -z "$TABLE" ]; then
  echo "Usage: $0 -b <s3-bucket> -t <dynamodb-table> [-r <region>]" >&2
  exit 1
fi

REGION=${REGION:-us-east-1}

terraform init \
  -backend-config="bucket=${BUCKET}" \
  -backend-config="key=envs/prod/terraform.tfstate" \
  -backend-config="region=${REGION}" \
  -backend-config="dynamodb_table=${TABLE}"
