import json
import os
import boto3
import logging
import time
import requests  # Use requests for making HTTP calls to Payroc
from botocore.exceptions import ClientError

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize clients and environment variables
dynamodb = boto3.resource('dynamodb')
PAYROC_API_URL = os.getenv('PAYROC_API_URL')  # Example: 'https://api.payroc.com'
PAYROC_API_KEY = os.getenv('PAYROC_API_KEY')  # Example: Payroc API Key

refund_table = dynamodb.Table(os.getenv('REFUND_TABLE'))
audit_table = dynamodb.Table(os.getenv('AUDIT_TABLE'))

def lambda_handler(event, context):
    transaction_id = event.get('transaction_id')
    refund_amount = event.get('refund_amount')
    currency = event.get('currency')
    
    if not (transaction_id and refund_amount and currency):
        logger.error("Missing required fields in the event payload.")
        return {
            'statusCode': 400,
            'body': json.dumps('Error: Missing required refund details.')
        }

    try:
        # Call Payroc to process the refund
        refund_response = initiate_refund(transaction_id, refund_amount, currency)
        
        if refund_response['status'] == 'SUCCESS':
            log_refund_in_dynamodb(transaction_id, refund_amount, currency, refund_response)
            log_audit_trail(transaction_id, refund_amount, currency, "SUCCESS", refund_response)
            
            logger.info("Refund processed successfully for transaction ID %s", transaction_id)
            return {
                'statusCode': 200,
                'body': json.dumps('Refund processed successfully')
            }
        else:
            logger.error("Refund failed: %s", refund_response['message'])
            log_audit_trail(transaction_id, refund_amount, currency, "FAILED", refund_response)
            return {
                'statusCode': 500,
                'body': json.dumps(f"Refund failed: {refund_response['message']}")
            }
    except Exception as e:
        logger.error("Unexpected error processing refund: %s", str(e))
        log_audit_trail(transaction_id, refund_amount, currency, "ERROR", str(e))
        return {
            'statusCode': 500,
            'body': json.dumps('Error processing refund')
        }

def initiate_refund(transaction_id, amount, currency):
    """Call Payroc API for refund processing."""
    try:
        refund_url = f"{PAYROC_API_URL}/refund"
        headers = {
            'Authorization': f'Bearer {PAYROC_API_KEY}',
            'Content-Type': 'application/json'
        }
        data = {
            'transaction_id': transaction_id,
            'amount': amount,
            'currency': currency
        }

        # Make the HTTP request to Payroc to process the refund
        response = requests.post(refund_url, json=data, headers=headers)
        
        if response.status_code == 200:
            return {'status': 'SUCCESS', 'response': response.json()}
        else:
            logger.error("Payroc refund API error: %s", response.text)
            return {'status': 'FAILED', 'message': response.json().get('message', 'Refund failed')}
    except requests.exceptions.RequestException as e:
        logger.error("Network error calling Payroc API: %s", str(e))
        return {'status': 'FAILED', 'message': str(e)}

def log_refund_in_dynamodb(transaction_id, amount, currency, refund_response):
    """Logs the refund transaction details in DynamoDB."""
    try:
        refund_table.put_item(
            Item={
                'TransactionID': transaction_id,
                'RefundAmount': amount,
                'Currency': currency,
                'RefundStatus': refund_response['status'],
                'RefundDetails': refund_response['response'],
                'Timestamp': int(time.time())  # Timestamp for record creation
            }
        )
    except ClientError as e:
        logger.error("Error logging refund to DynamoDB: %s", e.response['Error']['Message'])

def log_audit_trail(transaction_id, amount, currency, status, details):
    """Logs the audit trail of the refund process in DynamoDB."""
    try:
        audit_table.put_item(
            Item={
                'TransactionID': transaction_id,
                'Action': 'REFUND',
                'Amount': amount,
                'Currency': currency,
                'Status': status,
                'Details': json.dumps(details),  # Ensures details are JSON serializable
                'Timestamp': int(time.time())  # Timestamp for audit trail
            }
        )
    except ClientError as e:
        logger.error("Error logging audit trail to DynamoDB: %s", e.response['Error']['Message'])
