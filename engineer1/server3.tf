# #########################
# Instance
# #########################
resource "aws_instance" "server3" {
  ami                     = var.ami_id
  disable_api_termination = false
  ebs_optimized           = true
  instance_type           = local.nodes_instance_type
  key_name                = aws_key_pair.this.id
  monitoring              = true
  user_data_base64        = data.template_cloudinit_config.server3.rendered
  credit_specification {
    cpu_credits = "unlimited"
  }
  network_interface {
    network_interface_id = aws_network_interface.server3.id
    device_index         = 0
  }
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = 20
    volume_type           = "gp2"
  }
  volume_tags = merge(
    local.common_tags,
    {
      "Name"    = "${local.resource_name_prefix}-server3"
      "service" = "server3"
    },
  )
  tags = merge(
    local.common_tags,
    {
      "Name"    = "${local.resource_name_prefix}-server3"
      "service" = "server3"
    },
  )

  depends_on = [aws_network_interface.server3]
}

# #########################
# Network Interface
# #########################

resource "aws_network_interface" "server3" {
  subnet_id       = module.vpc.public_subnets[2]
  private_ips     = [cidrhost(module.vpc.public_subnets_cidr_blocks[2], 6)]
  security_groups = [aws_security_group.server3.id]
  tags = merge(
    local.common_tags,
    {
      "Name"    = "${local.resource_name_prefix}-server3"
      "service" = "server3"
    },
  )
}

# #########################
# Security group
# #########################
resource "aws_security_group" "server3" {
  name        = substr(format("%s-%s", "${local.resource_name_prefix}-server3", replace(uuid(), "-", "")), 0, 32)
  description = "server3"
  vpc_id      = module.vpc.vpc_id
  tags = merge(
    local.common_tags,
    {
      "Name"    = "${local.resource_name_prefix}-server3"
      "service" = "server3"
    },
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_security_group_rule" "server3_all_egress" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All egress traffic"
  security_group_id = aws_security_group.server3.id
}

resource "aws_security_group_rule" "server3_all_ips_list" {
  type              = "ingress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = var.ips_list
  description       = "All ingress traffic from IPs list"
  security_group_id = aws_security_group.server3.id
}

resource "aws_security_group_rule" "server3_all_jumphost" {
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  source_security_group_id = aws_security_group.jumphost.id
  description              = "All ingress traffic from jumphost"
  security_group_id        = aws_security_group.server3.id
}

resource "aws_security_group_rule" "server3_all_server1" {
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  source_security_group_id = aws_security_group.server1.id
  description              = "All ingress traffic from server1"
  security_group_id        = aws_security_group.server3.id
}

resource "aws_security_group_rule" "server3_all_server2" {
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  source_security_group_id = aws_security_group.server2.id
  description              = "All ingress traffic from server2"
  security_group_id        = aws_security_group.server3.id
}

# #########################
# User data
# #########################

data "template_file" "server3" {
  template = file("${path.module}/templates/cloudinit_nodes.yml")

  vars = {
    hosts_b64           = base64encode(data.template_file.hosts.rendered)
    ssh_private_key_b64 = base64encode(file("${path.module}/templates/id_rsa"))
    hostname            = "server3"
  }
}

data "template_cloudinit_config" "server3" {
  gzip          = false
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.server3.rendered
  }
}

# #########################
# Outputs
# #########################

output "server3" {
  value = [
    sort(aws_network_interface.server3.private_ips)[0]
  ]
}
