#!/bin/bash

# Update the system
yum update -y

# Install Docker
yum install -y docker

# Start Docker service
systemctl start docker

# Enable Docker to start automatically after reboot
systemctl enable docker

# Add ec2-user to Docker group
usermod -aG docker ec2-user

# Pull Docker image
docker pull dilipdev714/miniapp:v1

# Run Docker container
docker run -d --name miniapp -p 80:5000 dilipdev714/miniapp:v1