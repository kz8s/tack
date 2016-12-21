variable "bucket-prefix" {}
variable "depends-id" {}
variable "name" {}

output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
output "aws-iam-role-etcd-id" { value = "${ aws_iam_role.master.id }" }
output "aws-iam-role-worker-id" { value = "${ aws_iam_role.worker.id }" }
output "iam-role-snapshot-arn" { value = "${ aws_iam_role.snapshot.arn }" }
output "instance-profile-name-master" { value = "${ aws_iam_instance_profile.master.name }" }
output "instance-profile-name-worker" { value = "${ aws_iam_instance_profile.worker.name }" }
