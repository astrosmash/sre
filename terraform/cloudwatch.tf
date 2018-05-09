resource "aws_cloudwatch_log_group" "docker-logs" {
  name = "docker-logs"
}

resource "aws_cloudwatch_log_metric_filter" "docker-logs-errors" {
  name = "DockerLogsErrorCount"
  pattern = "Error"
  log_group_name = "${aws_cloudwatch_log_group.docker-logs.name}"

  metric_transformation {
    name = "IncomingLogEventErrors"
    namespace = "Logs"
    value = "1"
  }
}

resource "aws_sns_topic" "docker_cloudwatch_notifications" {
  name = "docker_cloudwatch_notifications"
}

/* This doesn't work at the moment. Please subscribe to the topic manually. https://www.terraform.io/docs/providers/aws/r/sns_topic_subscription.html#email
resource "aws_sns_topic_subscription" "docker_cloudwatch_notifications" {
  topic_arn = "${aws_sns_topic.docker_cloudwatch_notifications.arn}"
  protocol = "email"
  endpoint = "root@route32.net"
} */

resource "aws_cloudwatch_metric_alarm" "docker-logs-errors" {
  alarm_name = "docker-logs-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "IncomingLogEventErrors"
  namespace = "Logs"
  period = "60"
  statistic = "Sum"
  threshold = "1"
  alarm_description = "This alerts if docker-logs-errors filter has matched something"
  alarm_actions = ["${aws_sns_topic.docker_cloudwatch_notifications.arn}"]
  insufficient_data_actions = []
  depends_on = ["aws_sns_topic.docker_cloudwatch_notifications"]
}
