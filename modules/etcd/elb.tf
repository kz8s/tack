resource "aws_elb" "external" {
  name = "kz8s-apiserver-${replace(var.name, "/(.{0,17})(.*)/", "$1")}"

  cross_zone_load_balancing = false

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8080/"
    interval = 30
  }

  instances = [ "${ aws_instance.etcd.*.id }" ]
  idle_timeout = 3600

  listener {
    instance_port = 443
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }

  security_groups = [ "${ var.external-elb-security-group-id }" ]
  subnets = [ "${ split(",", var.subnet-ids-public) }" ]

  tags {
    builtWith = "terraform"
    kz8s = "${ var.name }"
    Name = "kz8s-apiserver"
    role = "apiserver"
    version = "${ var.hyperkube-tag }"
    visibility = "public"
    KubernetesCluster = "${ var.name }"
  }
}
