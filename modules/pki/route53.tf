resource "aws_route53_record" "pki" {

  name = "pki"

  records = [
    "${ aws_instance.pki.private_ip }"
  ]

  ttl = "300"
  type = "A"
  zone_id = "${ var.internal-zone-id }"

}
