data "template_file" "user-data" {

  template = "${ file( "${ path.module }/user-data.yml" ) }"

  vars {
    internal-tld = "${ var.internal-tld }"
    s3-bucket = "${ var.s3-bucket }"
  }

}
