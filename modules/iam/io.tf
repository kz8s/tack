variable "bucket-prefix" {}
variable "depends-id" {}
variable "name" {}

output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
output "instance-profile-name-master" { value = "${ aws_iam_instance_profile.master.name }" }
output "instance-profile-name-worker" { value = "${ aws_iam_instance_profile.worker.name }" }
