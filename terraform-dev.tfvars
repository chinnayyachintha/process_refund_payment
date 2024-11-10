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
elavon_api_url = "https://api.elavon.com/refund"

# specify the Elavon API Token for authentication
elavon_api_token = "your_elavon_api_token"