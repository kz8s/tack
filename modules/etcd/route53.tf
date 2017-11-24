resource "aws_route53_record" "A-etcd" {
  name = "etcd"
  records = [ "${ aws_instance.etcd.*.private_ip }" ]
  ttl = "300"
  type = "A"
  zone_id = "${ var.internal-zone-id }"
}

resource "aws_route53_record" "A-etcds" {
  count = "${var.cluster-size}"
  #count = "${ length( aws_instance.etcd.*.id ) }"

  name = "etcd${ count.index+1 }"
  ttl = "300"
  type = "A"
  records = [
    "${ element(aws_instance.etcd.*.private_ip, count.index) }"
  ]
  zone_id = "${ var.internal-zone-id }"
}

resource "aws_route53_record" "etcd-client-tcp" {
  name = "_etcd-client._tcp"
  ttl = "300"
  type = "SRV"
  records = [ "${ formatlist("0 0 2379 %v", aws_route53_record.A-etcds.*.fqdn) }" ]
  zone_id = "${ var.internal-zone-id }"
}

resource "aws_route53_record" "etcd-server-tcp" {
  name = "_etcd-server-ssl._tcp"
  ttl = "300"
  type = "SRV"
  records = [ "${ formatlist("0 0 2380 %v", aws_route53_record.A-etcds.*.fqdn) }" ]
  zone_id = "${ var.internal-zone-id }"
}
