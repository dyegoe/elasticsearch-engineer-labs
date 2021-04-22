module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.78.0"

  name = local.resource_name_prefix

  azs                  = local.azs
  cidr                 = var.cidr
  public_subnets       = cidrsubnets(var.cidr, 2, 2, 2)
  enable_ipv6          = false
  enable_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = local.common_tags
}
