# Output for the S3 bucket used for backup storage
output "s3_backup_bucket_name" {
  value = aws_s3_bucket.refund_backup_bucket.bucket
  description = "Name of the S3 bucket used to store refund backup files"
}

output "s3_backup_bucket_arn" {
  value = aws_s3_bucket.refund_backup_bucket.arn
  description = "ARN of the S3 bucket used to store refund backup files"
}

# Output for the DynamoDB table used for audit trail
output "audit_table_name" {
  value = aws_dynamodb_table.audit_table.name
  description = "Name of the DynamoDB table used for logging audit trail of backup operations"
}

output "audit_table_arn" {
  value = aws_dynamodb_table.audit_table.arn
  description = "ARN of the DynamoDB table used for logging audit trail of backup operations"
}

# Output for the DynamoDB table used for storing refund details
output "refund_table_name" {
  value = aws_dynamodb_table.refund_table.name
  description = "Name of the DynamoDB table used for storing refund transaction details"
}

output "refund_table_arn" {
  value = aws_dynamodb_table.refund_table.arn
  description = "ARN of the DynamoDB table used for storing refund transaction details"
}

# Outputs for the Lambda function handling the backup logic
output "backup_lambda_function_name" {
  value = aws_lambda_function.refund_backup_lambda.function_name
  description = "Name of the Lambda function for processing refund backups"
}

output "backup_lambda_function_arn" {
  value = aws_lambda_function.refund_backup_lambda.arn
  description = "ARN of the Lambda function for processing refund backups"
}

output "backup_lambda_function_role" {
  value = aws_iam_role.refund_backup_lambda_role.arn
  description = "ARN of the IAM role associated with the refund backup Lambda function"
}
