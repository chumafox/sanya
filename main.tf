terraform {
  required_version = ">=1.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ubuntu" {
  count                  = 3
  ami                    = "ami-04505e74c0741db8d"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.asg.id]
  key_name               = "rsa"

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, Hilton" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

}

resource "aws_security_group" "asg" {
  name = "my_asg"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_key_pair" "my_key" {
  key_name   = "rsa"
  public_key = file("~/.ssh/id_rsa.pub")
}
