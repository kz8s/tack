resource "aws_cloudwatch_metric_alarm" "worker-memory-high" {
    alarm_name = "${ var.name }-mem-util-high-worker"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "Linux/System"
    period = "300"
    statistic = "Average"
    threshold = "80"
    alarm_description = "This metric monitors ec2 memory for high utilization on agent hosts"
    alarm_actions = [
        "${ aws_autoscaling_policy.worker-scale-up.arn }"
    ]
    dimensions {
        AutoScalingGroupName = "${ aws_autoscaling_group.worker.name }"
    }
}

resource "aws_cloudwatch_metric_alarm" "worker-memory-low" {
    alarm_name = "${ var.name }-mem-util-low-worker"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "Linux/System"
    period = "300"
    statistic = "Average"
    threshold = "40"
    alarm_description = "This metric monitors ec2 memory for low utilization on agent hosts"
    alarm_actions = [
        "${ aws_autoscaling_policy.worker-scale-down.arn }"
    ]
    dimensions {
        AutoScalingGroupName = "${ aws_autoscaling_group.worker.name }"
    }
}

resource "aws_cloudwatch_metric_alarm" "worker-cpu-high" {
    alarm_name = "${ var.name }-cpu-util-high-worker"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "300"
    statistic = "Average"
    threshold = "80"
    alarm_description = "This metric monitors ec2 cpu for high utilization on agent hosts"
    alarm_actions = [
        "${ aws_autoscaling_policy.worker-scale-up.arn }"
    ]
    dimensions {
        AutoScalingGroupName = "${ aws_autoscaling_group.worker.name }"
    }
}

resource "aws_cloudwatch_metric_alarm" "worker-cpu-low" {
    alarm_name = "${ var.name }-cpu-util-low-worker"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "300"
    statistic = "Average"
    threshold = "40"
    alarm_description = "This metric monitors ec2 cpu for low utilization on agent hosts"
    alarm_actions = [
        "${ aws_autoscaling_policy.worker-scale-down.arn }"
    ]
    dimensions {
        AutoScalingGroupName = "${ aws_autoscaling_group.worker.name }"
    }
}