data "template_file" "calico" {
  template = "${ file( "${ path.module }/../_templates/addons/calico.yaml" )}"

  vars {
		pod-ip-range = "${ var.pod-ip-range }"
    internal-tld = "${ var.internal-tld }"
  }
}

