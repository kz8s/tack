resource "aws_route53_zone" "internal" {
  comment = "Kubernetes cluster DNS (internal)"
  name = "${ var.internal-tld }"
  tags {
    builtWith = "terraform"
    KubernetesCluster = "${ var.name }"
    Name = "k8s-${ var.name }"
  }
  vpc_id = "${ var.vpc-id }"
}

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

resource "aws_route53_record" "CNAME-master" {
  name = "master"
  records = [ "etcd.${ var.internal-tld }" ]
  ttl = "300"
  type = "CNAME"
  zone_id = "${ aws_route53_zone.internal.zone_id }"
}

resource "template_file" "discover-client" {
  count = "${ length( split(",", var.etcd-ips) ) }"
  template = "0 0 2379 etcd${ count.index + 1 }.${ var.internal-tld }"
}

resource "template_file" "discover-server" {
  count = "${ length( split(",", var.etcd-ips) ) }"
  template = "0 0 2380 etcd${ count.index + 1 }.${ var.internal-tld }"
}

resource "aws_route53_record" "etcd-client-tcp" {
  name = "_etcd-client._tcp"
  ttl = "300"
  type = "SRV"
  records = [ "${ template_file.discover-client.*.rendered }" ]
  zone_id = "${ aws_route53_zone.internal.zone_id }"
}

resource "aws_route53_record" "etcd-server-tcp" {
  name = "_etcd-server-ssl._tcp"
  ttl = "300"
  type = "SRV"
  records = [ "${ template_file.discover-server.*.rendered }" ]
  zone_id = "${ aws_route53_zone.internal.zone_id }"
}

resource "null_resource" "dummy_dependency" {
  depends_on = [
    "aws_route53_record.etcd-server-tcp",
    "aws_route53_record.A-etcd",
  ]
}
