resource "aws_cloudwatch_metric_alarm" "rds" {
    alarm_name = "sm-db-inactive-alarm"
    namespace = "AWS/RDS"
    comparison_operator = "LessThanThreshold"
    evaluation_periods = 4
    metric_name = "CPUUtilization"
    period = 900
    statistic = "Average"
    threshold = 5
    actions_enabled = true
    alarm_actions = [aws_sns_topic.sns_rds.arn]
    alarm_description = "Turn RDS off if it's idle."
    datapoints_to_alarm = 3
    dimensions = {
        DBInstanceIdentifier = var.db_identifier
    }
}

resource "aws_cloudwatch_metric_alarm" "elb" {
    alarm_name = "sm-delete-elb-if-inactive"
    namespace = "AWS/NetworkELB"
    comparison_operator = "LessThanThreshold"
    evaluation_periods = 4
    metric_name = "ProcessedBytes"
    period = 900
    statistic = "Sum"
    threshold = 1
    actions_enabled = true
    alarm_actions = [aws_sns_topic.sns_elb.arn]
    alarm_description = "Delete Load Balancers that are not being used."
    datapoints_to_alarm = 3
    dimensions = {
        LoadBalancer = var.lb_arn_suffix
    }
}

resource "aws_sns_topic" "sns_rds" {
    name = "sm-stop-rds-if-idle"
}

resource "aws_sns_topic" "sns_elb" {
    name = "sm-delete-load-balancers-if-idle" 
}

resource "aws_sns_topic_subscription" "rds" {
    topic_arn = aws_sns_topic.sns_rds.arn
    protocol = "lambda"
    endpoint = "arn:aws:lambda:us-east-2:052911266688:function:stop-rds"
}

resource "aws_sns_topic_subscription" "elb" {
    topic_arn = aws_sns_topic.sns_elb.arn
    protocol = "lambda"
    endpoint = "arn:aws:lambda:us-east-2:052911266688:function:delete-lbs"
}