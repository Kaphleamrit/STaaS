#!/bin/bash

# Update and upgrade system packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Node.js (latest LTS version 16.x)
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Git
sudo apt-get install -y git

# Clone your frontend app repository
cd /home/ubuntu
git clone https://github.com/Kaphleamrit/graduateProjectWeb.git


# Navigate into the app directory
cd /home/ubuntu/graduateProjectWeb

# Install Node.js dependencies
npm install

# Install AWS SDK
npm install aws-sdk

# Install PM2 globally using npm
sudo npm install -g pm2

# Set dynamic SQS Queue URL from Terraform output (ensure it is passed correctly from Terraform)
echo "export SQS_QUEUE_URL=${sqs_queue_url}" >> /etc/environment

# Load environment variables into the current session
source /etc/environment

# Start the Node.js app using PM2
pm2 start App.js

# Ensure PM2 starts on system boot
pm2 startup systemd
pm2 save

