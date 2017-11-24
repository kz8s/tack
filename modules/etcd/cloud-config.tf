data "template_file" "cloud-config-bootstrap" {
  count = "${ length( split(",", var.etcd-ips) ) }"
  template = "${ file( "${ path.module }/cloud-config-bootstrap.yml" )}"

  vars {
    fqdn = "etcd${ count.index + 1 }.${ var.internal-tld }"
    s3-bucket = "${ var.s3-bucket }"
  }
}

data "template_file" "cloud-config" {
  count = "${ length( split(",", var.etcd-ips) ) }"
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    apiserver-count = "${ length( split(",", var.etcd-ips) ) }"
    cluster-domain = "${ var.cluster-domain }"
    cluster-token = "etcd-cluster-${ var.name }"
    dns-service-ip = "${ var.dns-service-ip }"
    external-elb = "${ aws_elb.external.dns_name }"
    fqdn = "etcd${ count.index + 1 }.${ var.internal-tld }"
    hostname = "etcd${ count.index + 1 }"
    hyperkube = "${ var.k8s["hyperkube-image"] }:${ var.k8s["hyperkube-tag"] }"
    hyperkube-image = "${ var.k8s["hyperkube-image"] }"
    hyperkube-tag = "${ var.k8s["hyperkube-tag"] }"
    internal-tld = "${ var.internal-tld }"
    ip-k8s-service = "${ var.ip-k8s-service }"
    s3-bucket = "${ var.s3-bucket }"
    pod-ip-range = "${ var.pod-ip-range }"
    region = "${ var.aws["region"] }"
    service-cluster-ip-range = "${ var.service-cluster-ip-range }"
  }
}

resource "aws_s3_bucket_object" "calico-addon" {
  key                    = "addons/calico/calico.yml"
  bucket                 = "${var.s3-bucket}"
  content = "${ data.template_file.calico.rendered }"
}
