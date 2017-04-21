variable "depends-id" {}
variable "name" {}
variable "s3-bucket-arn" {}

output "depends-id" { value = "${ null_resource.dummy_dependency.id }" }
output "aws-iam-role-bastion-id" { value = "${ aws_iam_role.bastion.id }" }
output "aws-iam-role-etcd-id" { value = "${ aws_iam_role.master.id }" }
output "aws-iam-role-pki-id" { value = "${ aws_iam_role.pki.id }" }
output "aws-iam-role-worker-id" { value = "${ aws_iam_role.worker.id }" }
output "instance-profile-name-bastion" { value = "${ aws_iam_instance_profile.bastion.name }" }
output "instance-profile-name-master" { value = "${ aws_iam_instance_profile.master.name }" }
output "instance-profile-name-pki" { value = "${ aws_iam_instance_profile.pki.name }" }
output "instance-profile-name-worker" { value = "${ aws_iam_instance_profile.worker.name }" }
