resource "aws_sqs_queue" "fifo_queue" {
  name                       = "my-fifo-queue.fifo"
  fifo_queue                 = true
  content_based_deduplication = true

  tags = {
    Name = "MyFifoQueue"
  }
}
