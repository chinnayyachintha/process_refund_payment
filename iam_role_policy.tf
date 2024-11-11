# IAM role and policies for the Lambda functions, giving them permissions 
# to access DynamoDB, S3, Secrets Managerand CloudWatch.

resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}-PaymentRefundLambdaRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Policy for DynamoDB access and S3 backup
# Update IAM policy for Lambda to access Secrets Manager
resource "aws_iam_role_policy" "lambda_secrets_access" {
  name = "${var.project_name}-RefundProcessorpolicy"
  role = aws_iam_role.lambda_execution_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "${aws_secretsmanager_secret.payroc_secret.arn}"
    },
    {
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Scan"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_dynamodb_table.refund_transactions.arn}",
        "${aws_dynamodb_table.payment_audit_trail.arn}"
      ]
    },
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.refund_backup_bucket.arn}/*"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}
