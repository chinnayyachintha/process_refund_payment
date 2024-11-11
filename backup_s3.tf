# Set Up S3 Bucket for Backups
# create an S3 bucket to store backups of the DynamoDB tables.
# S3 bucket to store the backups and configure it with versioning and a lifecycle policy to manage data retention

# Create S3 Bucket for refund backups
resource "aws_s3_bucket" "refund_backup_bucket" {
  bucket = "${var.project_name}-refund-backup-bucket"

  tags = merge(
    {
      Name = "${var.project_name}-refund_backup_bucket"
    },
    var.tags
  )
}

# Enable versioning for the S3 bucket using aws_s3_bucket_versioning
resource "aws_s3_bucket_versioning" "refund_backups_versioning" {
  bucket = aws_s3_bucket.refund_backup_bucket.bucket  # Corrected to use refund_backup_bucket

  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle Configuration for S3 Bucket to manage backup data retention
resource "aws_s3_bucket_lifecycle_configuration" "refund_backup_lifecycle" {
  bucket = aws_s3_bucket.refund_backup_bucket.bucket  # Corrected to use refund_backup_bucket

  rule {
    id     = "backup-lifecycle"
    status = "Enabled"

    expiration {
      days = 365  # Set the number of days for expiration
    }

    filter {
      prefix = ""  # Filter for all objects, can be adjusted as needed
    }
  }
}
