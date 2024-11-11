# Set Up CloudWatch Event for Scheduled Backups
# create a CloudWatch Event that triggers a Lambda function to back up the DynamoDB tables on a daily schedule. 
# The Lambda function will use the AWS SDK to create a backup of each table and store it in the specified S3 bucket.

# CloudWatch Event to trigger backup Lambda function daily
resource "aws_cloudwatch_event_rule" "daily_backup_schedule" {
  name        = "DailyBackupSchedule"
  description = "Daily trigger for refund data backup"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "backup_lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_backup_schedule.name
  target_id = "BackupLambdaFunction"
  arn       = aws_lambda_function.backup_lambda.arn
}

# Grant permissions for CloudWatch Events to invoke the backup Lambda
resource "aws_lambda_permission" "allow_cloudwatch_events" {
  statement_id  = "AllowExecutionFromCloudWatchEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backup_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_backup_schedule.arn
}

