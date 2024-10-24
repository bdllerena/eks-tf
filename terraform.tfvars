# Cluster Configuration
cluster_name    = "my-fargate-cluster"
cluster_version = "1.31"  # Latest stable EKS version as of 2024

# VPC Configuration 
vpc_cidr = "10.0.0.0/16"
azs      = ["us-east-1a", "us-east-1b", "us-east-1f"]  # Modify based on your region

private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

# Tags
tags = {
  Environment = "production"
  Project     = "my-fargate-project"
  Terraform   = "true"
  Owner       = "platform-team"
}

# Optional: If you need to define specific IAM policies or roles
fargate_iam_policies = [
  "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
]

# Region
aws_region = "us-east-1"  # Change to your desired region
s3_bucket_name = "p-bucket-k8s"