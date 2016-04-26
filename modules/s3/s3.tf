resource "aws_s3_bucket" "ssl" {
  acl = "private"
  bucket = "${ var.bucket-prefix }"
  force_destroy = true
  tags {
    Cluster = "${ var.name }"
    Name = "k8s"
    builtWith = "terraform"
  }

  provisioner "local-exec" {
    command = "HYPERKUBE=${ var.hyperkube-image } PODMASTER=${ var.podmaster-image } ${ path.module }/s3-cp ${ var.bucket-prefix }"
  }

}
