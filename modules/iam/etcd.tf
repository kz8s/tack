resource "aws_iam_role" "master" {
  name = "k8s-master-${ var.name }"
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

resource "aws_iam_instance_profile" "master" {
  name = "k8s-master-${ var.name }"
  roles = [
    "${ aws_iam_role.master.name }"
  ]
}

resource "aws_iam_role_policy" "master" {
  name = "k8s-master-${ var.name }"
  role = "${ aws_iam_role.master.id }"
  policy = <<EOS
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:List*",
        "s3:Get*"
      ],
      "Effect": "Allow",
      "Resource": [ "arn:aws:s3:::${ var.bucket-prefix }/*" ]
    },
    {
      "Action": [
        "ec2:*",
        "elasticloadbalancing:*"
        ],
      "Effect": "Allow",
      "Resource": [ "*" ]
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
