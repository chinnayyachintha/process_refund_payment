# Create the Lambda Function for Backup Process
# Create a Lambda function that processes backup requests and updates the Backup table in DynamoDB.

resource "aws_lambda_function" "refund_backup" {
  function_name = "${var.project_name}-RefundBackup"
  handler       = "refund_backup.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_backup_role.arn
  filename      = "lambda_files/refund_backup.zip"

  environment {
    variables = {
      AUDIT_TABLE = aws_dynamodb_table.payment_audit_trail.name
      S3_BUCKET   = aws_s3_bucket.refund_backups.bucket
    }
  }
}

# IAM Role for Backup Lambda with permissions for DynamoDB and S3
resource "aws_iam_role" "lambda_backup_role" {
  name = "${var.project_name}-RefundBackupRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = var.tags
}

# Attach a policy to allow access to DynamoDB and S3 for backups
resource "aws_iam_role_policy" "lambda_backup_policy" {
  name = "backup-access-policy"
  role = aws_iam_role.lambda_backup_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:Scan"]
        Resource = aws_dynamodb_table.payment_audit_trail.arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.refund_backups.arn}/*"
      },
    ]
  })
}
