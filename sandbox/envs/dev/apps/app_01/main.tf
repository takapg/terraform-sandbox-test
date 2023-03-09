resource "aws_iam_role" "main" {
  name = "${var.product}-${var.env}-app-01-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "main" {
  name = "${var.product}-${var.env}-app-01-instance-profile"
  role = aws_iam_role.main.name
}

data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "main" {
  ami                  = data.aws_ami.amazon_linux2.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.main.name
  subnet_id            = var.subnet_id
  user_data            = <<EOF
#!/bin/bash
aws s3 cp s3://${var.s3_bucket_name}/${var.s3_object_name}
cat ${var.s3_object_name}
EOF

  tags = {
    Name = "${var.product}-${var.env}-app-01-instance"
  }
}
