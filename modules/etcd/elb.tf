resource "aws_elb" "external" {
  name = "kz8s-apiserver-${replace(var.name, "/(.{0,17})(.*)/", "$1")}"

  cross_zone_load_balancing = false

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 6
    timeout = 3
    target = "SSL:443"
    interval = 10
  }

  idle_timeout = 3600

  listener {
    instance_port = 443
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }

  security_groups = [ "${ var.external-elb-security-group-id }" ]
  subnets = [ "${ var.subnet-id-public }" ]

  tags {
    builtWith = "terraform"
    kz8s = "${ var.name }i"
    Name = "kz8s-apiserver"
    role = "apiserver"
    version = "${ var.k8s["hyperkube-tag"] }"
    visibility = "public"
    KubernetesCluster = "${ var.name }"
  }
}

resource "aws_elb_attachment" "master" {
  count = "${ length( split(",", var.etcd-ips) ) }"

  elb      = "${ aws_elb.external.id }"
  instance = "${ element(aws_instance.etcd.*.id, count.index) }"
}
