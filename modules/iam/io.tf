variable "bucket-prefix" {}
variable "name" {}

output "instance-profile-name-master" { value = "${ aws_iam_instance_profile.master.name }" }
output "instance-profile-name-worker" { value = "${ aws_iam_instance_profile.worker.name }" }

variable "depends-id" {}
output "depends-id" { value = "${null_resource.dummy_dependency.id}" }
