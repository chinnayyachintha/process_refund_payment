import json
import os
import boto3
import logging
import time
from botocore.exceptions import ClientError

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize clients
dynamodb = boto3.resource('dynamodb')
payment_processor_client = boto3.client('your-payment-processor')  # Replace with actual payment processor client
refund_table = dynamodb.Table(os.environ['REFUND_TABLE'])
audit_table = dynamodb.Table(os.environ['AUDIT_TABLE'])

def lambda_handler(event, context):
    try:
        # Extract refund details from event
        transaction_id = event['transaction_id']
        refund_amount = event['refund_amount']
        currency = event['currency']

        # Call payment processor to process the refund
        refund_response = initiate_refund(transaction_id, refund_amount, currency)
        
        if refund_response['status'] == 'SUCCESS':
            # Log the successful refund in the Refund DynamoDB table
            log_refund_in_dynamodb(transaction_id, refund_amount, currency, refund_response)
            
            # Log the refund operation in the Audit DynamoDB table
            log_audit_trail(transaction_id, refund_amount, currency, "SUCCESS", refund_response)
            
            logger.info("Refund processed successfully for transaction ID %s", transaction_id)
            return {
                'statusCode': 200,
                'body': json.dumps('Refund processed successfully')
            }
        else:
            logger.error("Refund failed: %s", refund_response['message'])
            # Log the failed operation in the Audit DynamoDB table
            log_audit_trail(transaction_id, refund_amount, currency, "FAILED", refund_response)
            return {
                'statusCode': 500,
                'body': json.dumps('Refund failed')
            }
    except Exception as e:
        logger.error("Error processing refund: %s", str(e))
        # Log the error in the Audit DynamoDB table
        log_audit_trail(transaction_id, refund_amount, currency, "ERROR", str(e))
        return {
            'statusCode': 500,
            'body': json.dumps('Error processing refund')
        }

def initiate_refund(transaction_id, amount, currency):
    # Replace with actual payment processor API call for refund
    try:
        # Example placeholder for a refund API call
        response = payment_processor_client.refund(
            TransactionId=transaction_id,
            Amount=amount,
            CurrencyCode=currency
        )
        return {'status': 'SUCCESS', 'response': response}
    except ClientError as e:
        logger.error("Payment processor error: %s", e.response['Error']['Message'])
        return {'status': 'FAILED', 'message': e.response['Error']['Message']}

def log_refund_in_dynamodb(transaction_id, amount, currency, refund_response):
    try:
        refund_table.put_item(
            Item={
                'TransactionID': transaction_id,
                'RefundAmount': amount,
                'Currency': currency,
                'RefundStatus': refund_response['status'],
                'RefundDetails': refund_response['response'],
            }
        )
    except ClientError as e:
        logger.error("Error logging refund to DynamoDB: %s", e.response['Error']['Message'])

def log_audit_trail(transaction_id, amount, currency, status, details):
    try:
        audit_table.put_item(
            Item={
                'TransactionID': transaction_id,
                'Action': 'REFUND',
                'Amount': amount,
                'Currency': currency,
                'Status': status,
                'Details': str(details),
                'Timestamp': int(time.time())  # Timestamp for audit trail
            }
        )
    except ClientError as e:
        logger.error("Error logging audit trail to DynamoDB: %s", e.response['Error']['Message'])
