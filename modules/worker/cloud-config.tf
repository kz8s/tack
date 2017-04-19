data "template_file" "cloud-config" {
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    cluster-domain = "${ var.cluster-domain }"
    dns-service-ip = "${ var.dns-service-ip }"
    hyperkube-image = "${ var.k8s["hyperkube-image"] }"
    hyperkube-tag = "${ var.k8s["hyperkube-tag"] }"
    internal-tld = "${ var.internal-tld }"
    pki-s3-bucket = "${ var.pki-s3-bucket }"
    region = "${ var.aws["region"] }"
  }
}
