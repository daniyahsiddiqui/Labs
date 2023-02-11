terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5.0"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  region = "us-east-1"
}

variable "VPC" {
  type = string
  default = "vpc-07f7183299bc753ba"
  description = "VPC in which we need to create resources"
}
variable "CIDR" {
  type    = list(string)
  default = ["0.0.0.0/0"]
  description = "CIDR list for allowing traffic from SG"
}

variable "SUBNET" {
  type = string
  default = "subnet-06e17f4d97f0e34f3"
  description = "Public subnet for deploying the application"
}

variable "KEYNAME" {
  type = string
  default = "myPrivateKey"
  description = "Key name for the EC2"
}

variable "AMI" {
  type = string
  default = "ami-0b0dcb5067f052a63" 
  description = "AMI image id for EC2 instance to bake the EC2"
}

variable "EC2_TYPE" {
  type = string
  default = "t2.micro"
}

variable "S3_PATH" {
  type = string
  default = "s3://dan-usecase1-binaries/devops/usecase-1/"
  description = "S3 Path of an deployed image"
}

variable "APP_PATH" {
  type = string
  default = "/root/myproject"
  description = "Location of flask app installaion"
}

resource "aws_iam_role" "EC2_DefaultRole" {
  name = "EC2_DefaultRole"
  assume_role_policy = jsonencode({
   Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Sid = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "EC2_Policies" {
  name = "EC2_Policies"
  for_each = toset([
      "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
      "arn:aws:iam::aws:policy/AmazonS3FullAccess",
     ])
  roles = [aws_iam_role.EC2_DefaultRole.name]
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "rm_iam_profile" {
  name = "rm_iam_profile_usecase1"
  role = aws_iam_role.EC2_DefaultRole.name
}

resource "aws_security_group" "basic_http" {
  name = "sg_usecase1_http"
  description = "Web Security Group for HTTP"
  vpc_id =  var.VPC
  lifecycle {
      create_before_destroy = true
  }
  ingress = [
    {
      description = "Allow HTTP Traffic access"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = var.CIDR
      security_groups = []
      ipv6_cidr_blocks = []
      prefix_list_ids = []
    }
  ]

  egress = [
    {
      description = "Allow all outbound traffic"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [
        "0.0.0.0/0"]
      ipv6_cidr_blocks = [
        "::/0"]
      security_groups = []
      prefix_list_ids = []
    }
  ]
}

resource "aws_security_group" "basic_ssh" {
  name = "sg_usecase1_ssh"
  description = "Web Security Group for SSH access"
  vpc_id =  var.VPC
  lifecycle {
      create_before_destroy = true
  }
  ingress = [
    {
      description = "Allow SSH Traffic access"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = var.CIDR
      security_groups = []
      ipv6_cidr_blocks = []
      prefix_list_ids = []
    }
  ]

  egress = [
    {
      description = "Allow all outbound traffic"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [
        "0.0.0.0/0"]
      ipv6_cidr_blocks = [
        "::/0"]
      security_groups = []
      prefix_list_ids = []
    }
  ]

  tags = {
    Name = "rm-application"
  }
}

resource "aws_instance" "app_server" {
  ami = var.AMI
  key_name  = var.KEYNAME
  instance_type = var.EC2_TYPE
  subnet_id = var.SUBNET
  iam_instance_profile = aws_iam_instance_profile.rm_iam_profile.name  
  associate_public_ip_address = true
  vpc_security_group_ids = [
	aws_security_group.basic_http.id,
	aws_security_group.basic_ssh.id]
  user_data = <<EOF
                  #!/bin/bash
                  echo "Starting user_data"
                  sudo su -
                  yum -y install pip
                  mkdir "${var.APP_PATH}" && cd "$_"
                  sleep 2m
                  aws s3 cp "${var.S3_PATH}" . --recursive
                  cd app/
                  pip install flask
                  pip install *.whl -t "${var.APP_PATH}" 
                  echo "export FLASK_APP=${var.APP_PATH}/usecases/usecase-1/my_application/application.py"  >> /etc/profile
                  source /etc/profile
                  nohup flask run --host=0.0.0.0 --port 80 > log.txt 2>&1 &
                  echo "Application started"
                  echo "End user_data"
                EOF
  tags = {
    Name = "rm-application"
  }
}
