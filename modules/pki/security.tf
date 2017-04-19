resource "aws_security_group" "pki" {

  description = "k8s pki security group"

  egress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
    cidr_blocks = [ "${ var.cidr-vpc }" ]
  }

  name = "kz8s-pki-${ var.name }"

  tags {
    KubernetesCluster = "${ var.name }"
    Name = "kz8s-pki-${ var.name }"
    builtWith = "terraform"
  }

  vpc_id = "${ var.vpc-id }"
  
}
