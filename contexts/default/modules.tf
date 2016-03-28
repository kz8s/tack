resource "aws_cloudwatch_log_group" "k8s" {
  name = "k8s-${ var.name }"
  retention_in_days = 3
}

module "k8s" {
  source = "../../modules/k8s"
  name = "${ var.name }"
}

module "s3" {
  source = "../../modules/s3"
  cluster-id = "${ module.k8s.cluster-id }"

  bucket-prefix = "${ var.aws.account-id }-${ var.name }"
  name = "${ var.name }"
}

module "vpc" {
  source = "../../modules/vpc"
  cluster-id = "${ module.k8s.cluster-id }"

  azs = "${ var.aws.azs }"
  cidr = "${ var.cidr.vpc }"
  name = "${ var.name }"
  region = "${ var.aws.region }"
}

module "security" {
  source = "../../modules/security"
  cluster-id = "${ module.k8s.cluster-id }"

  cidr-allow-ssh = "${ var.cidr.allow-ssh }"
  cidr-vpc = "${ var.cidr.vpc }"
  name = "${ var.name }"
  vpc-id = "${ module.vpc.id }"
}

module "iam" {
  source = "../../modules/iam"

  bucket-prefix = "${ module.s3.bucket-prefix }"
  name = "${ var.name }"
}

module "route53" {
  source = "../../modules/route53"
  cluster-id = "${ module.k8s.cluster-id }"

  etcd-ips = "${ var.etcd-ips }"
  name = "${ var.name }"
  internal-tld = "${ var.internal-tld }"
  vpc-id = "${ module.vpc.id }"
}

module "etcd" {
  source = "../../modules/etcd"
  cluster-id = "${ module.k8s.cluster-id }"

  aws-region = "${ var.aws.region }"
  ami-id = "${ var.coreos-aws.ami }"
  bucket-prefix = "${ module.s3.bucket-prefix }"
  external-elb-security-group-id = "${ module.security.external-elb-id }"
  etcd-ips = "${ var.etcd-ips }"
  etcd-security-group-id = "${ module.security.etcd-id }"
  instance-profile-name = "${ module.iam.instance-profile-name-master }"
  instance-type = "${ var.instance-type.etcd }"
  internal-tld = "${ var.internal-tld }"
  key-name = "${ var.aws.key-name }"
  name = "${ var.name }"
  subnet-ids = "${ module.vpc.subnet-ids }"
  vpc-cidr = "${ var.cidr.vpc }"
  vpc-id = "${ module.vpc.id }"
}

module "bastion" {
  source = "../../modules/bastion"
  cluster-id = "${ module.k8s.cluster-id }"

  ami-id = "${ var.coreos-aws.ami }"
  bucket-prefix = "${ module.s3.bucket-prefix }"
  cidr-allow-ssh = "${ var.cidr.allow-ssh }"
  instance-type = "${ var.instance-type.bastion }"
  key-name = "${ var.aws.key-name }"
  name = "${ var.name }"
  security-group-id = "${ module.security.bastion-id }"
  subnet-ids = "${ module.vpc.subnet-ids }"
  vpc-id = "${ module.vpc.id }"
}

module "worker" {
  source = "../../modules/worker"
  cluster-id = "${ module.k8s.cluster-id }"

  desired-capacity = 3
  aws-region = "${ var.aws.region }"
  ami-id = "${ var.coreos-aws.ami }"
  bucket-prefix = "${ module.s3.bucket-prefix }"
  instance-profile-name = "${ module.iam.instance-profile-name-worker }"
  instance-type = "${ var.instance-type.worker }"
  internal-tld = "${ var.internal-tld }"
  key-name = "${ var.aws.key-name }"
  name = "${ var.name }"
  security-group-id = "${ module.security.worker-id }"
  // subnet-ids = "${ module.vpc.subnet-ids-private }"
  subnet-ids = "${ module.vpc.subnet-ids }"
  vpc-id = "${ module.vpc.id }"
}

module "kubeconfig" {
  source = "../../modules/kubeconfig"
  // cluster-id = "${ module.k8s.cluster-id }"

  admin-key-pem = ".cfssl/k8s-admin-key.pem"
  admin-pem = ".cfssl/k8s-admin.pem"
  ca-pem = ".cfssl/ca.pem"
  master-elb = "${ module.etcd.external-elb }"
  name = "${ var.name }"
  cluster-name = "${ var.name }"
}

resource "null_resource" "initialize" {

  triggers {
    bastion-ip = "${ module.bastion.ip }"
    # todo: change trigger to etcd elb dns name
    etcd-ips = "${ module.etcd.internal-ips }"
    etcd-elb = "${ module.etcd.external-elb }"
  }

  connection {
    agent = true
    bastion_host = "${ module.bastion.ip }"
    bastion_user = "core"
    host = "10.0.0.10"
    user = "core"
  }

  provisioner "remote-exec" {
    inline = [
      "echo -",
      "echo ❤ Polling for etcd life - this could take a minute",
      "/bin/bash -c 'until curl --silent http://127.0.0.1:2379/version; do echo ❤ trying to connect to etcd...; sleep 5; done'",
      "sleep 1",
      "echo ✓ etcd is alive!",
      "echo -",
      "echo ❤ Polling for kube-apiserver - this could take a minute",
      "/bin/bash -c 'until /opt/bin/kubectl cluster-info; do echo ❤ trying to connect to kube-apiserver...; sleep 3; done'",
      "echo ✓ kube-apiserver is alive!",
      "echo -",
      "echo ✓ Creating 'kube-system' namespace...",
      "/opt/bin/kubectl create namespace kube-system",
      "echo -",
      "echo ✓ Read scheduler key from etcd:",
      "etcdctl get scheduler",
      "echo -",
      "echo ✓ Read controller key from etcd:",
      "etcdctl get controller",
      "echo -",
      "echo ✓ Setting LogEntries token...",
      "etcdctl set /logentries.com/token 0674598a-c17f-4219-aeb3-382b7b6af176",
      "echo -",
      "echo ✓ Setting Sysdig Cloud access key...",
      "etcdctl set /sysdigcloud.com/access_key 735e7fb3-846a-4d29-8966-c40118e530b9",
    ]
  }

  provisioner "local-exec" {
    command = <<LOCALEXEC
echo "---"
echo "❤ Polling for ELB DNS propagation - this could take a bit"
until nslookup ${ module.etcd.external-elb } &>/dev/null; do echo "❤ trying to lookup etcd ELB..." && sleep 5; done
sleep 1
echo "✓ etcd ELB DNS record is live!"
echo "---"
echo "❤ Polling for cluster life - this could take a minute (or more)"
until kubectl cluster-info &>/dev/null; do echo "❤ trying to connect to cluster..." && sleep 5; done
sleep 1
echo "✓ Cluster is live!"
echo "---"
echo "✓ Get Nodes"
kubectl get nodes
echo "---"
echo "✓ Creating Kubernetes Add-Ons..."
kubectl create -f ../../manifests/addons
echo "---"
echo "✓ Get Services (kube-system)"
kubectl get svc --namespace=kube-system
echo "---"
echo "✓ Get Replication Controllers (kube-system)"
kubectl get rc --namespace=kube-system
echo "---"
echo "✓ Get Pods (kube-system)"
kubectl get pods --namespace=kube-system
echo "---"
echo "✓ Creating busybox test pod..."
kubectl create -f ../../test/pods/busybox.yml
echo "---"
echo "✓ Get Pods"
kubectl get pods
LOCALEXEC
  }
}
