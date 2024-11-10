output "refund_table_name" {
  value = aws_dynamodb_table.refunds.name
}

output "payment_audit_trail_table_name" {
  value = aws_dynamodb_table.payment_audit_trail.name
}

output "backup_bucket_name" {
  value = aws_s3_bucket.refund_backups.bucket
}

output "refund_processor_lambda_arn" {
  value = aws_lambda_function.refund_processor.arn
}

output "backup_lambda_arn" {
  value = aws_lambda_function.refund_backup.arn
}
