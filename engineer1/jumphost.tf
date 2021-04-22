# #########################
# Instance
# #########################
resource "aws_instance" "jumphost" {
  ami                     = var.ami_id
  disable_api_termination = false
  ebs_optimized           = true
  instance_type           = local.jumphost_instance_type
  key_name                = aws_key_pair.this.id
  monitoring              = true
  user_data_base64        = data.template_cloudinit_config.jumphost.rendered
  credit_specification {
    cpu_credits = "unlimited"
  }
  network_interface {
    network_interface_id = aws_network_interface.jumphost.id
    device_index         = 0
  }
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = 8
    volume_type           = "gp2"
  }
  volume_tags = merge(
    local.common_tags,
    {
      "Name"    = "${local.resource_name_prefix}-jumphost"
      "service" = "jumphost"
    },
  )
  tags = merge(
    local.common_tags,
    {
      "Name"    = "${local.resource_name_prefix}-jumphost"
      "service" = "jumphost"
    },
  )

  depends_on = [aws_network_interface.jumphost]
}

# #########################
# Network Interface
# #########################

resource "aws_network_interface" "jumphost" {
  subnet_id       = module.vpc.public_subnets[0]
  private_ips     = [cidrhost(module.vpc.public_subnets_cidr_blocks[0], 5)]
  security_groups = [aws_security_group.jumphost.id]
  tags = merge(
    local.common_tags,
    {
      "Name"    = "${local.resource_name_prefix}-jumphost"
      "service" = "jumphost"
    },
  )
}

# #########################
# Elastic IP
# #########################

resource "aws_eip" "jumphost" {
  vpc = true
  tags = merge(
    local.common_tags,
    {
      "Name"    = "${local.resource_name_prefix}-jumphost"
      "service" = "jumphost"
    },
  )
}

resource "aws_eip_association" "jumphost" {
  instance_id   = aws_instance.jumphost.id
  allocation_id = aws_eip.jumphost.id
}

# #########################
# Security group
# #########################
resource "aws_security_group" "jumphost" {
  name        = substr(format("%s-%s", "${local.resource_name_prefix}-jumphost", replace(uuid(), "-", "")), 0, 32)
  description = "jumphost"
  vpc_id      = module.vpc.vpc_id
  tags = merge(
    local.common_tags,
    {
      "Name"    = "${local.resource_name_prefix}-jumphost"
      "service" = "jumphost"
    },
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_security_group_rule" "jumphost_all_egress" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All egress traffic"
  security_group_id = aws_security_group.jumphost.id
}

resource "aws_security_group_rule" "jumphost_all_ips_list" {
  type              = "ingress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = var.ips_list
  description       = "All ingress traffic from IPs list"
  security_group_id = aws_security_group.jumphost.id
}

# #########################
# User data
# #########################

data "template_file" "jumphost" {
  template = file("${path.module}/templates/cloudinit.yml")

  vars = {
    hosts_b64           = base64encode(data.template_file.hosts.rendered)
    ssh_private_key_b64 = base64encode(file("${path.module}/templates/id_rsa"))
    ssh_config          = base64encode(file("${path.module}/templates/ssh_config"))
    nginx_kibana        = base64encode(file("${path.module}/templates/nginx_kibana.conf"))
  }
}

data "template_cloudinit_config" "jumphost" {
  gzip          = false
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.jumphost.rendered
  }
}

# #########################
# Outputs
# #########################

output "jumphost" {
  value = [
    aws_eip.jumphost.public_ip,
    aws_eip.jumphost.public_dns,
    sort(aws_network_interface.jumphost.private_ips)[0]
  ]
}
