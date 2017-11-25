data "template_file" "cloud-config-bootstrap" {
  #count = "${ var.cluster-size }"
  template = "${ file( "${ path.module }/cloud-config-bootstrap.yml" )}"

  vars {
    #fqdn = "etcd${ count.index + 1 }.${ var.internal-tld }"
    fqdn = "etcd.${ var.internal-tld }"
    s3-bucket = "${ var.s3-bucket }"
  }
}

data "template_file" "cloud-config" {
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    apiserver-count = "${ var.cluster-size }"
    cluster-domain = "${ var.cluster-domain }"
    dns-service-ip = "${ var.dns-service-ip }"
    external-elb = "${ aws_elb.external.dns_name }"
    fqdn = "etcd.${ var.internal-tld }"
    hostname = "etcd${ count.index + 1 }"
    hyperkube = "${ var.k8s["hyperkube-image"] }:${ var.k8s["hyperkube-tag"] }"
    hyperkube-image = "${ var.k8s["hyperkube-image"] }"
    hyperkube-tag = "${ var.k8s["hyperkube-tag"] }"
    internal-tld = "${ var.internal-tld }"
    k8s-service-ip = "${ var.k8s-service-ip }"
    s3-bucket = "${ var.s3-bucket }"
    pod-ip-range = "${ var.pod-ip-range }"
    region = "${ var.aws["region"] }"
    service-cluster-ip-range = "${ var.service-cluster-ip-range }"
    calico_addon_etag = "${aws_s3_bucket_object.calico-addon.etag}"
  }
}
