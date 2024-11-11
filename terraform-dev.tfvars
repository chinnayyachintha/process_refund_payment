# specify the region where the resources will be created
aws_region = "ca-central-1"

# specify the project name to be used as a prefix for all resources
project_name = "refund-payment"

# specify tags to be assigned to resources
tags = {
  Environment = "dev"
  Project     = "refundPaymentaudittrail"
}

# specify the Elavon API URL and Token for refund processing
payroc_api_url = "https://api.payroc.com/refund"

# specify the Elavon API Token for authentication
payroc_auth_token = "your_payroc_aut_token"