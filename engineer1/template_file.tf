data "template_file" "hosts" {
  template = file("${path.module}/templates/hosts")

  vars = {
    jumphost_private_ip = sort(aws_network_interface.jumphost.private_ips)[0]
    server1_private_ip  = sort(aws_network_interface.server1.private_ips)[0]
    server2_private_ip  = sort(aws_network_interface.server2.private_ips)[0]
    server3_private_ip  = sort(aws_network_interface.server3.private_ips)[0]
  }
}
