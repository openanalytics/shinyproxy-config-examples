module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${var.cluster_name}-vpc"
  cidr = "10.150.0.0/16"

  azs             = var.aws_zones
  private_subnets = ["10.150.1.0/24", "10.150.2.0/24"]
  public_subnets  = ["10.150.10.0/24", "10.150.11.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.common_tags
}
