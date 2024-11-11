# Lambda functions handle the refund processing, audit logging, and backup.

# Refund Processor Lambda function
# Refund Processor Lambda function with Secrets Manager integration
resource "aws_lambda_function" "refund_processor_lambda" {
  filename         = "lambda_files/refund_processor.zip"  # Replace with path to your Lambda code
  function_name    = "RefundProcessor"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "refund_processor.handler"
  runtime          = "python3.8"

  environment {
    variables = {
      TRANSACTIONS_TABLE = aws_dynamodb_table.refund_transactions.name
      AUDIT_TABLE        = aws_dynamodb_table.payment_audit_trail.name
      PAYROC_SECRET_ARN  = aws_secretsmanager_secret.payroc_secret.arn
    }
  }
}
# Backup Lambda function for periodic backups to S3
resource "aws_lambda_function" "backup_lambda" {
  filename         = "lambda_files/backup_lambda.zip"  # Replace with path to your Lambda code
  function_name    = "RefundDataBackup"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "backup_lambda.handler"
  runtime          = "python3.8"

  environment {
    variables = {
      AUDIT_TABLE = aws_dynamodb_table.payment_audit_trail.name
      S3_BUCKET   = aws_s3_bucket.refund_backup_bucket.bucket
    }
  }
}
