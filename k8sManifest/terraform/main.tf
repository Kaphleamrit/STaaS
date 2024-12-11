provider "aws" {
  region = "us-east-1"
}

# EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "zap-cluster"
  cluster_version = "1.23"
  node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
    }
  }
}

# SQS Queue for URLs
resource "aws_sqs_queue" "zap_queue" {
  name                       = "zap-queue.fifo"
  fifo_queue                 = true
  content_based_deduplication = true
}

# SES Domain Setup (replace with your domain)
resource "aws_ses_domain_identity" "domain" {
  domain = "your-domain.com"
}

resource "aws_ses_identity_policy" "ses_policy" {
  identity = aws_ses_domain_identity.domain
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": "ses:SendEmail",
      "Resource": "*"
    }]
  })
}

# IAM Role for the Pod to Access SQS and SES
resource "aws_iam_role" "zap_role" {
  name = "zap-pod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "zap_policy" {
  name = "zap-policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = aws_sqs_queue.zap_queue.arn
      },
      {
        Effect = "Allow",
        Action = "ses:SendEmail",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "zap_policy_attach" {
  role       = aws_iam_role.zap_role.name
  policy_arn = aws_iam_policy.zap_policy.arn
}
