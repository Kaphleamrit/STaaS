module "vpc" {
  source = "./vpc"
}

module "ec2" {
  source              = "./ec2"
  ami_id                = "ami-0e86e20dae9224db8"
  vpc_id              = module.vpc.vpc_id
  subnet_id           = module.vpc.public_subnet_id
  instance_profile    = "ec2_instance_profile"
  key_name = "gradPKeypair"
  sqs_arn = module.sqs.arn
  security_group_ids = [module.ec2.ec2_sg]
  sqs_queue_url = module.sqs.sqs_queue_url
}

module "sqs" {
  source = "./sqs"
}
