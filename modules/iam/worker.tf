resource "aws_iam_role" "worker" {
  assume_role_policy = <<EOS
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOS

  name = "k8s-worker-${ var.name }"
}

resource "aws_iam_instance_profile" "worker" {
  name = "k8s-worker-${ var.name }"
  roles = [ "${ aws_iam_role.worker.name }" ]
}

resource "aws_iam_role_policy" "worker" {
  name = "k8s-worker-${var.name}"
  role = "${ aws_iam_role.worker.id }"
  policy = <<EOS
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:List*",
        "s3:Get*"
      ],
      "Resource": [ "arn:aws:s3:::${ var.bucket-prefix }/*" ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:CreateRoute",
        "ec2:DeleteRoute",
        "ec2:ReplaceRoute",
        "ec2:DescribeRouteTables",
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    }
  ]
}
EOS
}

resource "null_resource" "dummy_dependency" {
  depends_on = [
    "aws_iam_role.worker",
    "aws_iam_role_policy.worker",
    "aws_iam_instance_profile.worker",
  ]
}
