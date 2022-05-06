
resource "aws_iam_role_policy" "example" {
  name   = "example"
  role   = aws_iam_role.example.name
  policy = jsonencode({
    "Statement" = [{

    }],
  })
}
resource "aws_instance" "example" {
  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.example
  depends_on = [
    aws_iam_role_policy.example,
  ]
}
resource "aws_instance" "server" {
  count = 4
  ami = "ami-a1b2c3d4"
  instance_type = "t2.micro"
}

resource "aws_iam_user" "the-accounts" {
  for_each = toset( ["Todd", "James", "Alice", "Dottie"] )
  name     = each.key
}