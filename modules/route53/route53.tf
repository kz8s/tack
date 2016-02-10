resource "aws_route53_zone" "internal" {
  comment = "Kubernetes cluster DNS (internal)"
  name = "k8s"
  tags {
    Name = "k8s"
    Cluster = "${ var.name }"
  }
  vpc_id = "${ var.vpc-id }"
}

/*resource "aws_route53_record" "master" {
  name = "master"
  ttl = "300"
  type = "A"
  records = [ "10.0.0.15" ]
  zone_id = "${ aws_route53_zone.k8s-internal.zone_id }"
}*/

resource "aws_route53_record" "A-etcd" {
  name = "etcd"
  records = [ "${ split(",", var.etcd-ips) }" ]
  ttl = "300"
  type = "A"
  zone_id = "${ aws_route53_zone.internal.zone_id }"
}

resource "aws_route53_record" "A-etcds" {
  count = "${ length( split(",", var.etcd-ips) ) }"

  name = "etcd${ count.index+1 }"
  ttl = "300"
  type = "A"
  records = [
    "${ element(split(",", var.etcd-ips), count.index) }"
  ]
  zone_id = "${ aws_route53_zone.internal.zone_id }"
}

resource "aws_route53_record" "etcd-client-tcp" {
  name = "_etcd-client._tcp"
  ttl = "300"
  type = "SRV"
  records = [
    "0 0 2379 etcd1.k8s",
    "0 0 2379 etcd2.k8s",
    "0 0 2379 etcd3.k8s"
  ]
  zone_id = "${ aws_route53_zone.internal.zone_id }"
}

resource "aws_route53_record" "etcd-server-tcp" {
  name = "_etcd-server._tcp"
  ttl = "300"
  type = "SRV"
  records = [
    "0 0 2380 etcd1.k8s",
    "0 0 2380 etcd2.k8s",
    "0 0 2380 etcd3.k8s"
  ]
  zone_id = "${ aws_route53_zone.internal.zone_id }"
}
