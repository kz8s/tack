resource "aws_route53_record" "CNAME-master" {
  name = "master"
  records = [ "apiserver.${ var.internal-tld }" ]
  ttl = "300"
  type = "CNAME"
  zone_id = "${ var.internal-zone-id }"
}

resource "aws_route53_record" "A-apiserver" {
  name = "apiserver"
  records = [ "${ aws_instance.apiserver.*.private_ip }" ]
  ttl = "60"
  type = "A"
  zone_id = "${ var.internal-zone-id }"
}
