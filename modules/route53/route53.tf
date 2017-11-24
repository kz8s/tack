# TODO: module that creates internal route53 zone from which other modules can
# depend on.
resource "aws_route53_zone" "internal" {
  comment = "Kubernetes [tack] cluster DNS (internal)"
  name = "${ var.internal-tld }"
  tags {
    builtWith = "terraform"
    KubernetesCluster = "${ var.name }"
    kz8s = "${ var.name }"
    Name = "k8s-${ var.name }"
  }
  vpc_id = "${ var.vpc-id }"
}

resource "null_resource" "dummy_dependency" {
  depends_on = [
    "aws_route53_zone.internal",
  ]
}
