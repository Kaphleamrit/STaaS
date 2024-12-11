import boto3
import os
import subprocess
import json
import time

# AWS Configuration
AWS_REGION = "us-east-2"
SQS_QUEUE_URL = "https://sqs.us-east-2.amazonaws.com/637423571752/my-fifo-queue.fifo"
REPORT_DIR = "/zap/reports"

# Initialize AWS clients
# sqs = boto3.client('sqs', region_name=AWS_REGION)
sqs = boto3.client('sqs', region_name=AWS_REGION, )

# Poll SQS for messages containing URLs
def poll_sqs():
    print("Polling SQS for messages...")
    response = sqs.receive_message(
        QueueUrl=SQS_QUEUE_URL,
        MaxNumberOfMessages=1,  # Fetch one message at a time
        WaitTimeSeconds=10      # Long-polling (waits up to 10 seconds if no messages are available)
    )
    
    # Check if any messages were returned
    if 'Messages' in response:
        for message in response['Messages']:
            # Parse the message body
            body = json.loads(message['Body'])
            url = body.get('url', None)
            email = body.get('email', None)
            print("url", "email")
            if url and email:
                print("Processing message with URL: {} and Email: {}".format(url, email))
                run_owasp_zap_scan(url)
                # Delete the message from the SQS queue after processing
                sqs.delete_message(QueueUrl=SQS_QUEUE_URL, ReceiptHandle=message['ReceiptHandle'])
                print("Message processed and deleted")
            else:
                print("Invalid message format: 'url' or 'email' is missing.")
    else:
        print("No messages available. Polling again...")

# Run OWASP ZAP scan for the given URL``    
def run_owasp_zap_scan(url):
    # Construct the report file name properly
    report_name = "zap_report_{}.html".format(url.replace('https://', '').replace('/', '_'))
    report_path = "/zap/wrk/{}".format(report_name)  # Ensure path is correct and avoid duplication
    print("Running ZAP scan for URL: {}".format(url))
    
    # Run the ZAP scan
    subprocess.Popen([
        'zap-baseline.py', '-t', url, '-r', report_path
    ])
    print("ZAP scan for {} complete. Report saved to {}".format(url, report_path))


if __name__ == '__main__':
    # Continuously poll the SQS queue and run scans
    try:
        while True:
            poll_sqs()
            # Sleep for a short time before polling again to avoid excessive API calls
            time.sleep(5)
    except KeyboardInterrupt:
        print("Script interrupted. Exiting...")
