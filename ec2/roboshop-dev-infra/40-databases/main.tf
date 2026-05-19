resource "aws_instance" "mongodb" {
    ami           =   local.ami_id
    instance_type = "t3.micro"
    subnet_id = local.database_subnet_ids
    vpc_security_group_ids = [local.mongodb_sg_id]
    tags = merge(
        {
            Name = "${var.project}-${var.environment}-mongodb"
        },
        local.common_tags
 )
}

resource "terraform_data" "bootstrap-mongodb" {
  triggers_replace = [
    aws_instance.mongodb.id,
  ]

connection {
      type        = "ssh"
      host        = aws_instance.mongodb.private_ip
      user        = "ec2-user"
      password = "DevOps321"
  }

provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh mongodb"
    ]
  }
}
    
resource "aws_instance" "redis" {
    ami           =   local.ami_id
    instance_type = "t3.micro"
    subnet_id = local.database_subnet_ids
    vpc_security_group_ids = [local.redis_sg_id]
    tags = merge(
        {
            Name = "${var.project}-${var.environment}-redis"
        },
        local.common_tags
    )
}

resource "terraform_data" "bootstrap-redis" {
  triggers_replace = [
    aws_instance.redis.id,
  ]

connection {
      type        = "ssh"
      host        = aws_instance.redis.private_ip
      user        = "ec2-user"
      password = "DevOps321"
  }

provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh redis"
    ]
  }
}


resource "aws_instance" "rabbitmq" {
    ami           =   local.ami_id
    instance_type = "t3.micro"
    subnet_id = local.database_subnet_ids
    vpc_security_group_ids = [local.rabbitmq_sg_id]
    tags = merge(
        {
            Name = "${var.project}-${var.environment}-rabbitmq"
        },
        local.common_tags
  )
}

resource "terraform_data" "bootstrap-rabbitmq" {
  triggers_replace = [
    aws_instance.rabbitmq.id,
  ]

connection {
      type        = "ssh"
      host        = aws_instance.rabbitmq.private_ip
      user        = "ec2-user"
      password = "DevOps321"
  }

provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh rabbitmq"
    ]
  }
}
resource "aws_ssm_parameter" "mysql_root_password" {
  name      = "/${var.project}/${var.environment}/mysql_root_password"
  type      = "SecureString"
  value     = "DevOps321"
  overwrite = true
}
resource "aws_instance" "mysql" {
    ami           =   local.ami_id
    instance_type = "t3.micro"
    subnet_id = local.database_subnet_ids
    vpc_security_group_ids = [local.mysql_sg_id]
      iam_instance_profile = aws_iam_instance_profile.mysql.name

    tags = merge(
        {
            Name = "${var.project}-${var.environment}-mysql"
        },
        local.common_tags
    )
    }

resource "terraform_data" "bootstrap-mysql" {
  triggers_replace = [
    aws_instance.mysql.id,
  ]
connection {
      type        = "ssh"
      host        = aws_instance.mysql.private_ip
      user        = "ec2-user"
      password = "DevOps321"
  }

provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh mysql ${var.environment}"
    ]
  }
}

