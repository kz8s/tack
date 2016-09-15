resource "aws_route53_record" "A-master" {
  name = "master"
  records = [ "${ split(",", join(",", aws_instance.master.*.private_ip)) }" ]
  ttl = "300"
  type = "A"
  zone_id = "${ var.internal-zone-id }"
}

resource "aws_route53_record" "A-masters" {
  count = "3"

  name = "master${ count.index+1 }"
  ttl = "300"
  type = "A"
  records = [
    "${ element(aws_instance.master.*.private_ip, count.index) }"
  ]
  zone_id = "${ var.internal-zone-id }"
}