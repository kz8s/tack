data "template_file" "cloud-config" {
  count = "${ length( split(",", var.etcd-ips) ) }"
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    cluster-domain = "${ var.cluster-domain }"
    cluster-token = "etcd-cluster-${ var.name }"
    dns-service-ip = "${ var.dns-service-ip }"
    etc-tar = "/manifests/etc.tar"
    fqdn = "etcd${ count.index + 1 }.${ var.internal-tld }"
    hostname = "etcd${ count.index + 1 }"
    hyperkube = "${ var.k8s["hyperkube-image"] }:${ var.k8s["hyperkube-tag"] }"
    hyperkube-image = "${ var.k8s["hyperkube-image"] }"
    hyperkube-tag = "${ var.k8s["hyperkube-tag"] }"
    internal-tld = "${ var.internal-tld }"
    ip-k8s-service = "${ var.ip-k8s-service }"
    pki-s3-bucket = "${ var.pki-s3-bucket }"
    pod-ip-range = "${ var.pod-ip-range }"
    region = "${ var.aws["region"] }"
    service-cluster-ip-range = "${ var.service-cluster-ip-range }"
  }
}
