# sqs/outputs.tf
output "arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.fifo_queue.arn  # Replace with the correct resource name in the sqs module
}

output "sqs_queue_url" {
    description = "Queue URL"
    value = aws_sqs_queue.fifo_queue.url
}