locals {
  common_tags = {
    terraform   = "true"
    environment = "lab"
    project     = "elasticsearch"
    workspace   = "engineer1"
  }
  azs                    = ["${var.region}a", "${var.region}b", "${var.region}c"]
  resource_name_prefix   = "elk-engineer1"
  jumphost_instance_type = "t3.nano"
  nodes_instance_type    = "t3.medium"
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_key_pair" "this" {
  key_name   = local.resource_name_prefix
  public_key = var.ssh_public_key
}
