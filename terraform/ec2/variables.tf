variable "instance_type" {
  description = "Type of EC2 instance to create"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Replace with your preferred AMI ID
}

variable "key_name" {
  description = "Key pair name to access the EC2 instance"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the EC2 instance will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the public subnet where the EC2 instance will be deployed"
  type        = string
}

variable "instance_profile" {
  description = "The IAM instance profile to attach to the EC2 instance"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the EC2 instance"
  type        = list(string)
}

variable "sqs_arn" {
  description = "ARN on the SQS FIFO"
  type = string
}

variable "sqs_queue_url" {
  description = "SQS queue URL"
  type = string
}