terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5.0"
    }
  }
  required_version = ">= 0.14.9"
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

resource "aws_iam_instance_profile" "rm_iam_profile" {
  name = "rm_iam_profile_usecase_4"
  role = "EC2_DefaultRole"
}

variable "EC2_TYPE" {
  type = string
  default = "t2.micro"
}

variable "S3_PATH" {
  type = string
  default = "s3://jenkins-webhooks/devops/usecase-1"
  description = "S3 Path of an deployed image"
}

resource "aws_security_group" "basic_http" {
  name = "sg_flask-rm"
  description = "Web Security Group for HTTP"
  vpc_id =  var.VPC
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
      self = true
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
      self = true
    }
  ]
}

resource "aws_security_group" "basic_ssh" {
  name = "sg_ssh-rm-usecase-1"
  description = "Web Security Group for HTTP"
  vpc_id =  var.VPC
  ingress = [
    {
      description = "Allow HTTP Traffic access"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = var.CIDR
      security_groups = []
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      self = true
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
      self = true
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
                  sudo yum -y install pip
                  mkdir /root/myproject
                  cd /root/myproject/
                  aws s3 cp "${var.S3_PATH}" . --recursive
                  ls -lrt
                  cd app/
                  pip install flask
                  pip install *.whl -t /root/myproject
                  echo "export FLASK_APP=/root/myproject/usecases/usecase-1/my_application/application.py"  >> /etc/profile
                  source /etc/profile
                  nohup flask run --host=0.0.0.0 --port 80 > log.txt 2>&1 &
                  echo "Application started"
                  echo "End user_data"
                EOF
  tags = {
    Name = "rm-application"
  }
}
