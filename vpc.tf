module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.cluster_name

  cidr = var.vpc_cidr
  azs  = var.azs

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = var.tags
}