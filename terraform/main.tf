provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("${path.module}/deployer-key.pub")
}


resource "aws_instance" "web" {
  ami           = "ami-0953476d60561c955"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  tags = {
    Name = "jenkins-ec2"
  }
}

output "ec2_ip" {
  value = aws_instance.web.public_ip
}
