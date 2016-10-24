resource "aws_lambda_permission" "snapshot" {
  statement_id = "AllowExecutionFromCloudWatchForSnapshots"
  action = "lambda:InvokeFunction"
  function_name = "${ aws_lambda_function.snapshot.arn }"
  principal = "events.amazonaws.com"
  source_arn = "${ aws_cloudwatch_event_rule.snapshot.arn }"
}

resource "aws_lambda_function" "snapshot" {
  filename = "${ path.module }/../../tmp/snapshot.zip"
  function_name = "snapshot-${ var.name }"
  handler = "snapshot.snapshot"
  runtime = "python2.7"
  source_code_hash = "${ base64sha256(data.template_file.init.rendered) }"

  role = "${ var.iam-role-snapshot-arn }"

  vpc_config {
    subnet_ids = ["${ split(",", var.subnet-ids) }"]
    security_group_ids = ["${ split(",", var.security-groups) }"]
  }
}

data "template_file" "init" {
  template = "${ file("${ path.module }/snapshot.py.tpl") }"

  vars {
    name = "${ var.name }"
  }
}

resource "archive_file" "init" {
  type = "zip"
  source_content_filename = "snapshot.py"
  source_content = "${ data.template_file.init.rendered }"
  output_path = "${ path.module }/../../tmp/snapshot.zip"
}