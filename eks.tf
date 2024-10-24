module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Enable Fargate logging
  fargate_profile_defaults = {
    iam_role_additional_policies = {
      additional = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
    }
  }

  # Define Fargate profiles instead of managed node groups
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        },
        {
          namespace = "kube-system"
        }
      ]
      subnet_ids = module.vpc.private_subnets
      tags       = var.tags
    },
    applications = {
      name = "applications"
      selectors = [
        {
          namespace = "applications"
        }
      ]
      subnet_ids = module.vpc.private_subnets
      tags       = var.tags
    }
  }

  # Create an OIDC provider for the cluster
  enable_irsa = true

  tags = var.tags
}

# Optional: Create IAM role for Fargate execution
resource "aws_iam_role" "fargate_pod_execution_role" {
  name = "${var.cluster_name}-fargate-pod-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_pod_execution_role.name
}