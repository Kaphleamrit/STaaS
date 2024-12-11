# Create an IAM Role for EC2
resource "aws_iam_role" "ec2_sqs_role" {
  name = "ec2_sqs_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach an SQS Access Policy to the role
resource "aws_iam_policy" "sqs_access_policy" {
  name        = "SQSAccessPolicy"
  description = "Policy to allow EC2 to access SQS FIFO queues"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = var.sqs_arn
      }
    ]
  })
}


# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach_sqs_policy" {
  role       = aws_iam_role.ec2_sqs_role.name
  policy_arn = aws_iam_policy.sqs_access_policy.arn
}

# Create the Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_sqs_role.name
}

resource "aws_security_group" "ec2_sg" {
  name_prefix = "ec2_sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SSH access, restrict as needed
  }

  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"] # HTTP access, restrict as needed
  # }

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nodejs_app" {
  ami                         = "ami-0c55b159cbfafe1f0" # Replace with your preferred AMI
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = var.instance_profile
  key_name                    = var.key_name # Replace with your key pair name

  user_data = templatefile("${path.module}/userdata.tpl", {
    sqs_queue_url = var.sqs_queue_url
  })
  tags = {
    Name = "NodeJSAppInstance"
  }

}
