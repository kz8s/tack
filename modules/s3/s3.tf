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
tar -cf - \
  -C manifests/system kube-apiserver.yml kube-podmaster.yml \
  -C ../common kube-proxy.yml \
  | aws s3 cp - s3://${ var.bucket-prefix }/manifests/etc.tar &&\
tar -cf - \
  -C manifests/system kube-controller-manager.yml kube-scheduler.yml \
  | aws s3 cp - s3://${ var.bucket-prefix }/manifests/srv.tar &&\
tar -cf -  \
  -C manifests/common kube-proxy.yml \
  -C ../worker kube-config.yml \
  | aws s3 cp - s3://${ var.bucket-prefix }/manifests/worker.tar
LOCAL_EXEC
  }
}
