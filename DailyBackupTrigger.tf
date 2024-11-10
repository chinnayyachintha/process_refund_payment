# Set Up CloudWatch Event for Scheduled Backups
# create a CloudWatch Event that triggers a Lambda function to back up the DynamoDB tables on a daily schedule. 
# The Lambda function will use the AWS SDK to create a backup of each table and store it in the specified S3 bucket.

resource "aws_cloudwatch_event_rule" "daily_backup_schedule" {
  name                = "${var.project_name}-DailyBackupSchedule"
  schedule_expression = "rate(24 hours)"
}

resource "aws_cloudwatch_event_target" "backup_lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_backup_schedule.name
  target_id = "RefundBackupLambda"
  arn       = aws_lambda_function.refund_backup.arn
}

# Allow CloudWatch Events to trigger the backup Lambda function
resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_backup" {
  statement_id  = "AllowCloudWatchInvokeBackup"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.refund_backup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_backup_schedule.arn
}

