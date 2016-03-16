resource "aws_elb" "external" {
  name = "k8s-${ var.name }-master-external"
  subnets = [ "${ split(",", var.subnet-ids) }" ]
  cross_zone_load_balancing = false
  security_groups = [ "${ var.external-elb-security-group-id }" ]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8080/"
    interval = 30
  }

  instances = [ "${ aws_instance.etcd.*.id }" ]

  listener {
    instance_port = 443
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }

  tags {
    // KubernetesCluster = "${ var.cluster-id }"
    builtWith = "terraform"
    Cluster = "${ var.name }"
    Name = "apiserver-public"
    role = "apiserver"
  }
}
