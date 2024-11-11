# Create a Secret in Secrets Manager for the Payroc API token
# Secrets Manager for storing sensitive information

resource "aws_secretsmanager_secret" "payroc_secret" {
  name        = "PayrocCredentials"
  description = "Credentials for Payroc API"
}

resource "aws_secretsmanager_secret_version" "payroc_secret_version" {
  secret_id     = aws_secretsmanager_secret.payroc_secret.id
  secret_string = jsonencode({
    api_key = var.payroc_api_url,         # Replace with actual API key for Payroc
    auth_token = var.payroc_auth_token    # Replace with actual authentication token for Payroc
  })
}
