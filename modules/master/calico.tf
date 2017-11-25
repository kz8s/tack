data "template_file" "calico" {
  template = "${ file( "${ path.module }/../_templates/addons/calico.yaml" )}"

  vars {
		pod-ip-range = "${ var.pod-ip-range }"
    internal-tld = "${ var.internal-tld }"
  }
}

data "template_file" "dns" {
  template = "${ file( "${ path.module }/../_templates/addons/dns.yaml" )}"

  vars {
		dns-service-ip = "${ var.dns-service-ip }"
    cluster-domain = "${ var.cluster-domain }"
  }
}

resource "aws_s3_bucket_object" "calico-addon" {
  key                    = "addons/calico/calico.yml"
  bucket                 = "${var.s3-bucket}"
  content = "${ data.template_file.calico.rendered }"
}

resource "aws_s3_bucket_object" "dns-addon" {
  key                    = "addons/dns/dns.yml"
  bucket                 = "${var.s3-bucket}"
  content = "${ data.template_file.dns.rendered }"
}
