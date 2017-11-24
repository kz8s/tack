data "template_file" "cloud-config" {
  #count = "${ length( split(",", var.etcd-ips) ) }"
  count = "${ var.cluster-size }"
  template = "${ file( "${ path.module }/cloud-config.yml" )}"

  vars {
    fqdn = "etcd${ count.index + 1 }.${ var.internal-tld }"
    cluster-token = "etcd-cluster-${ var.name }"
    hostname = "etcd${ count.index + 1 }"
    internal-tld = "${ var.internal-tld }"
    s3-bucket = "${ var.s3-bucket }"
  }
}
