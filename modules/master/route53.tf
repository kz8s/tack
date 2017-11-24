resource "aws_route53_record" "CNAME-master" {
  name = "master"
  records = [ "apiserver.${ var.internal-tld }" ]
  ttl = "300"
  type = "CNAME"
  zone_id = "${ var.internal-zone-id }"
}
