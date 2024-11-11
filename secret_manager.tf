# Create a Secret in Secrets Manager for the Payroc API token
resource "aws_secretsmanager_secret" "payroc_api_token" {
    name        = "payroc_api_token"
    description = "API token for Payroc payment processor"
}

# Create the Secret version with the actual token (replace with your token)
resource "aws_secretsmanager_secret_version" "payroc_api_token_version" {
    secret_id     = aws_secretsmanager_secret.payroc_api_token.id
    secret_string = jsonencode({
        payroc_api_token = var.payroc_api_token  # Replace with your actual API token
    })
}