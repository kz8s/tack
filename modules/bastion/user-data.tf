data "template_file" "user-data" {
  template = "${ file( "${ path.module }/user-data.yml" )}"

  vars {
    internal-tld = "${ var.internal-tld }"
    bucket = "${ var.bucket-prefix }"
    region = "${ var.region }"
    ssl-tar = "/ssl/k8s-etcd.tar"
  }
}
