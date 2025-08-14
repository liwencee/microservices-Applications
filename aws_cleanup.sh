#!/bin/bash
# AWS Account Cleanup Script
# WARNING: This will permanently delete resources in your account.
# Run only if you're sure you want to clean everything.

set -euo pipefail

# ====== CONFIGURATION ======
AWS_REGIONS=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

echo "🔍 Cleaning resources in AWS account: $(aws sts get-caller-identity --query Account --output text)"
echo "🗑  WARNING: This will delete ALL resources in ALL regions!"
read -p "Type 'CLEANUP' to continue: " CONFIRM
if [[ "$CONFIRM" != "CLEANUP" ]]; then
  echo "❌ Cleanup canceled."
  exit 1
fi

# Loop through all AWS regions
for REGION in $AWS_REGIONS; do
  echo "🌍 Processing region: $REGION"

  # ---- EC2 Instances ----
  INSTANCE_IDS=$(aws ec2 describe-instances --region $REGION \
    --query "Reservations[].Instances[?State.Name!='terminated'].InstanceId" --output text)
  if [[ -n "$INSTANCE_IDS" ]]; then
    echo "  🚀 Terminating EC2 instances..."
    aws ec2 terminate-instances --region $REGION --instance-ids $INSTANCE_IDS
  fi

  # ---- Load Balancers ----
  echo "  🌐 Deleting Load Balancers..."
  for LB_ARN in $(aws elbv2 describe-load-balancers --region $REGION --query "LoadBalancers[].LoadBalancerArn" --output text); do
    aws elbv2 delete-load-balancer --region $REGION --load-balancer-arn $LB_ARN
  done

  # ---- Auto Scaling Groups ----
  echo "  📉 Deleting Auto Scaling Groups..."
  for ASG in $(aws autoscaling describe-auto-scaling-groups --region $REGION --query "AutoScalingGroups[].AutoScalingGroupName" --output text); do
    aws autoscaling delete-auto-scaling-group --region $REGION --auto-scaling-group-name $ASG --force-delete
  done

  # ---- RDS Databases ----
  echo "  💾 Deleting RDS instances..."
  for DB in $(aws rds describe-db-instances --region $REGION --query "DBInstances[].DBInstanceIdentifier" --output text); do
    aws rds delete-db-instance --region $REGION --db-instance-identifier $DB --skip-final-snapshot
  done

  # ---- S3 Buckets ----
  echo "  📦 Emptying and deleting S3 buckets..."
  for BUCKET in $(aws s3api list-buckets --query "Buckets[].Name" --output text); do
    REGION_BUCKET=$(aws s3api get-bucket-location --bucket $BUCKET --query "LocationConstraint" --output text)
    REGION_BUCKET=${REGION_BUCKET:-us-east-1}
    if [[ "$REGION_BUCKET" == "$REGION" ]]; then
      aws s3 rm s3://$BUCKET --recursive
      aws s3api delete-bucket --bucket $BUCKET --region $REGION_BUCKET
    fi
  done

  # ---- CloudFormation Stacks ----
  echo "  📜 Deleting CloudFormation stacks..."
  for STACK in $(aws cloudformation describe-stacks --region $REGION --query "Stacks[].StackName" --output text); do
    aws cloudformation delete-stack --region $REGION --stack-name $STACK
  done

  # ---- EKS Clusters ----
  echo "  ☸ Deleting EKS clusters..."
  for CLUSTER in $(aws eks list-clusters --region $REGION --query "clusters[]" --output text); do
    aws eks delete-cluster --region $REGION --name $CLUSTER
  done

  # ---- EBS Volumes ----
  echo "  💽 Deleting unattached EBS volumes..."
  for VOL in $(aws ec2 describe-volumes --region $REGION --filters Name=status,Values=available --query "Volumes[].VolumeId" --output text); do
    aws ec2 delete-volume --region $REGION --volume-id $VOL
  done
done

echo "✅ All regions cleaned! You can now safely close your AWS account."
