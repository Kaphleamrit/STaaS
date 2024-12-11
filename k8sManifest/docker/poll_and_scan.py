import boto3
import os
import subprocess
import json
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# Initialize AWS clients for SQS and SES
sqs = boto3.client('sqs', region_name=os.getenv('AWS_REGION'))
ses = boto3.client('ses', region_name=os.getenv('AWS_REGION'))

# SQS queue URL
queue_url = os.getenv('SQS_QUEUE_URL')

# Poll the SQS queue for messages
def poll_sqs():
    response = sqs.receive_message(
        QueueUrl=queue_url,
        MaxNumberOfMessages=1,
        WaitTimeSeconds=10
    )
    
    if 'Messages' in response:
        for message in response['Messages']:
            body = json.loads(message['Body'])
            url = body['url']
            email = body['mail']
            
            # Trigger OWASP ZAP scan for the URL
            trigger_owasp_zap_scan(url, email)
            
            # Delete the message from the SQS queue
            sqs.delete_message(QueueUrl=queue_url, ReceiptHandle=message['ReceiptHandle'])

# Trigger an OWASP ZAP scan using the ZAP CLI
def trigger_owasp_zap_scan(url, email):
    # Run OWASP ZAP quick scan for the URL
    subprocess.run([
        'zap-cli', 'quick-scan', '--self-contained', '--start-options', '-daemon', '-host', 'localhost', '-port', '8080', url
    ])
    
    # Assuming ZAP generates a report as "zap_report.html"
    report_path = '/zap/reports/zap_report.html'
    
    # Send the scan report via email
    send_email(report_path, email)

# Send the OWASP ZAP report via AWS SES
def send_email(report_path, email_address):
    with open(report_path, 'r') as report_file:
        report_content = report_file.read()
    
    # Create email content
    msg = MIMEMultipart()
    msg['Subject'] = "OWASP ZAP Scan Report"
    msg['From'] = os.getenv('SES_EMAIL_SOURCE')
    msg['To'] = email_address
    
    body = MIMEText(report_content, 'html')
    msg.attach(body)
    
    # Send email via AWS SES
    ses.send_raw_email(
        Source=os.getenv('SES_EMAIL_SOURCE'),
        Destinations=[email_address],
        RawMessage={'Data': msg.as_string()}
    )

if __name__ == '__main__':
    # Continuously poll the SQS queue for new URLs to scan
    while True:
        poll_sqs()
