data "template_file" "cloud-config" {
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    bucket = "${ var.bucket-prefix }"
    cluster-domain = "${ var.cluster-domain }"
    dns-service-ip = "${ var.dns-service-ip }"
    hyperkube-image = "${ var.hyperkube-image }"
    hyperkube-tag = "${ var.hyperkube-tag }"
    internal-tld = "${ var.internal-tld }"
    region = "${ var.region }"
    ssl-tar = "/ssl/k8s-worker.tar"
  }
}
