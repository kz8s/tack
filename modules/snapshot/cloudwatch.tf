resource "aws_cloudwatch_event_rule" "snapshot" {
  name = "snapshot-${ var.name }"
  description = "Schedule snapshots of ebs volumes"

  schedule_expression = "rate(2 hours)"
}

resource "aws_cloudwatch_event_target" "snapshot" {
  rule = "${ aws_cloudwatch_event_rule.snapshot.name }"
  arn = "${ aws_lambda_function.snapshot.arn }"
}