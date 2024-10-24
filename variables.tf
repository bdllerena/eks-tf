variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
variable "s3_bucket_name" {
  description = "Bucket variables"
  type        = string
}
variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones for VPC"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "fargate_iam_policies" {
  description = "List of IAM policy ARNs to attach to Fargate pods"
  type        = list(string)
  default     = []
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}