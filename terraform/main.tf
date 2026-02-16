terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

resource "aws_instance" "devops_vm" {
  ami           = "ami-0a261c0e5f51090b1"
  instance_type = "t3.micro"
  key_name      = "devops-portfolio-key-tf"

  vpc_security_group_ids = [
    aws_security_group.devops_sg.id
  ]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y

              # Install Docker
              yum install -y docker
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ec2-user

              # Pull latest image
              docker pull piotrbia/devops-portfolio-app:${var.image_tag}
              
              # Run container
              docker run -d -p 8080:8080 --name app \
                piotrbia/devops-portfolio-app:${var.image_tag}

              EOF

  tags = {
    Name = "devops-portfolio-vm"
  }
}

resource "aws_security_group" "devops_sg" {
  name        = "devops-portfolio-sg"
  description = "Allow SSH and app access"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

