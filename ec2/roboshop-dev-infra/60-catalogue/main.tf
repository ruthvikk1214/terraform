resource "aws_instance" "catalogue" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  subnet_id              = local.private_subnet_ids[0]
  vpc_security_group_ids = [local.catalogue_sg_id]
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )
}

resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id,
  ]

  connection {
    type     = "ssh"
    host     = aws_instance.catalogue.private_ip
    user     = "ec2-user"
    password = "DevOps321"
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh catalogue"
    ]
  }
}
