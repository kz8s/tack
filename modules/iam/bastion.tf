resource "aws_iam_role" "bastion" {
  name = "kz8s-bastion-${ var.name }"

  assume_role_policy = <<EOS
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOS
}

resource "aws_iam_instance_profile" "bastion" {
  name = "kz8s-bastion-${ var.name }"
  role = "${ aws_iam_role.bastion.name }"
}

resource "aws_iam_role_policy" "bastion" {
  name = "kz8s-bastion-${ var.name }"
  role = "${ aws_iam_role.bastion.id }"
  policy = <<EOS
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:Get*"
      ],
      "Resource": [ "${ var.s3-bucket-arn }/*" ]
    }
  ]
}
EOS
}
