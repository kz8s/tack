resource "aws_s3_bucket" "ssl" {
  acl = "private"
  bucket = "${ var.bucket-prefix }"
  force_destroy = true
  tags {
    Cluster = "${ var.name }"
    Name = "ssl"
  }

  provisioner "local-exec" {
    command = <<LOCAL_EXEC
aws s3 cp .ssl s3://${ var.bucket-prefix }/ssl --recursive --exclude "*" --include "*.tar" &&\
# tar -C systemd -cf - . \
#  | aws s3 cp - s3://${ var.bucket-prefix }/systemd/master.tar &&\
tar -C manifests/system -cf - kube-apiserver.yml kube-podmaster.yml kube-proxy.yml \
  | aws s3 cp - s3://${ var.bucket-prefix }/manifests/etc.tar &&\
tar -C manifests/system -cf - kube-controller-manager.yml kube-scheduler.yml \
  | aws s3 cp - s3://${ var.bucket-prefix }/manifests/srv.tar
LOCAL_EXEC
  }
}
