resource "aws_instance" "example" {
  ami           = "ami-0220d79f3f480ecf5"
  instance_type = "t3.micro"
  vpc_security_group_ids = ["sg-0eec592803ede7730"]
  tags = {
    Name        = "terraform-remote-state"
    Project     = "roboshop"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.example.public_ip} > public_ip.txt"
  } 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    # #private_key = file("my-key.pem")
    host        = self.public_ip
  }
}


# resource "aws_security_group" "allow_tls" {
#   name        = "allow_tls"
#   description = "Allow TLS inbound traffic and all outbound traffic"
#  ## vpc_id      = aws_vpc.main.id
#
#   tags = {
#     Name = "allow_tls"
#   }
#
#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }
#
#   ingress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }
# }