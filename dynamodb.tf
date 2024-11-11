# Set Up DynamoDB Tables for Refund Records and Audit Trail
# create the Refunds and PaymentAuditTrail DynamoDB tables in Terraform.

# DynamoDB table for storing refund records
resource "aws_dynamodb_table" "refund_transactions" {
  name         = "${var.project_name}-RefundTransactions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "RefundID"

  attribute {
    name = "RefundID"
    type = "S"
  }

  attribute {
    name = "TransactionID"
    type = "S"
  }

  # Global Secondary Index for TransactionID
  global_secondary_index {
    name            = "TransactionID-index"
    hash_key        = "TransactionID"
    projection_type = "ALL" # You can change the projection type if needed
  }

  tags = merge(
    {
      Name = "${var.project_name}-RefundTransactions"
    },
    var.tags
  )
}

# DynamoDB table for storing audit trail records
resource "aws_dynamodb_table" "payment_audit_trail" {
  name         = "${var.project_name}-AuditTrail"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "AuditID"

  attribute {
    name = "AuditID"
    type = "S"
  }

  attribute {
    name = "TransactionID"
    type = "S"
  }

  # Global Secondary Index for TransactionID
  global_secondary_index {
    name            = "TransactionID-index"
    hash_key        = "TransactionID"
    projection_type = "ALL" # Change if specific attributes are needed in the index
  }

  tags = merge(
    {
      Name = "${var.project_name}-AuditTrail"
    },
    var.tags
  )
}
