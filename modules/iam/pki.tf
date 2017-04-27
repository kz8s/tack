resource "aws_iam_role" "pki" {

  name = "kz8s-pki-${ var.name }"

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


resource "aws_iam_instance_profile" "pki" {
  name = "kz8s-pki-${ var.name }"
  role = "${ aws_iam_role.pki.name }"
}


resource "aws_iam_role_policy" "pki" {

  name = "kz8s-pki-${ var.name }"

  policy = <<EOS
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Put*"
      ],
      "Effect": "Allow",
      "Resource": [ "${ var.s3-bucket-arn }/*" ]
    }
  ]
}
EOS

  role = "${ aws_iam_role.pki.id }"

}
