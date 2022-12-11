provider "aws" {
  profile = "default"
  region = "us-west-2"
}

variable "image_id" {
  type = string
  default = "ami-08d70e59c07c61a3a"
}

variable "security_groups_name" {
  type = list(string)
  default = [
    "s1",
    "s2"]
}

resource "aws_instance" "app_server" {
  ami = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
resource "aws_instance" "app_server" {
  ami = var.image_id
  instance_type = "t2.micro"
  security_groups = var.security_groups_name
  tags = {
    Name = "ExampleAppServerInstance"
  }
}