data "template_file" "kubeconfig" {
  template = <<EOF
kubectl config set-cluster cluster-${ var.name } \
  --embed-certs=true \
  --server=https://${ var.master-elb } \
  --certificate-authority=${ path.cwd }/${ var.ca-pem }

kubectl config set-credentials admin-${ var.name } \
  --embed-certs=true \
  --certificate-authority=${ path.cwd }/${ var.ca-pem } \
  --client-key=${ path.cwd }/${ var.admin-key-pem } \
  --client-certificate=${ path.cwd }/${ var.admin-pem }

kubectl config set-context ${ var.name } \
  --cluster=cluster-${ var.name } \
  --user=admin-${ var.name }
kubectl config use-context ${ var.name }

# Run this command to configure your kubeconfig:
# eval $(terraform output kubeconfig)
EOF
}

resource "null_resource" "kubeconfig" {

  provisioner "local-exec" {
    command = <<LOCAL_EXEC
mkdir -p ./tmp && cat <<'__USERDATA__' > ./tmp/kubeconfig
${data.template_file.kubeconfig.rendered}
__USERDATA__
LOCAL_EXEC
  }

  provisioner "local-exec" {
    command = <<LOCAL_EXEC
kubectl config set-cluster cluster-${ var.name } \
  --server=https://${ var.master-elb } \
  --certificate-authority=${ path.cwd }/${ var.ca-pem } &&\
kubectl config set-credentials admin-${ var.name } \
  --certificate-authority=${ path.cwd }/${ var.ca-pem } \
  --client-key=${ path.cwd }/${ var.admin-key-pem } \
  --client-certificate=${ path.cwd }/${ var.admin-pem } &&\
kubectl config set-context ${ var.name } \
  --cluster=cluster-${ var.name } \
  --user=admin-${ var.name } &&\
kubectl config use-context ${ var.name }
LOCAL_EXEC
  }

}
