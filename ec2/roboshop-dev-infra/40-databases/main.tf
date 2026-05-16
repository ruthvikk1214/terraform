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

resource "aws_iam_instance_profile" "mysql" {
  name = "${var.project}-${var.environment}-mysql"
  role = aws_iam_role.mysql.name
}
# resource "aws_iam_role_policy_attachment" "mysql_ssm" {
#   role       = aws_iam_role.mysql.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
# }

resource "terraform_data" "bootstrap-mysql" {
  triggers_replace = [
    aws_instance.mysql.id,
  ]
# depends_on = [
#   aws_ssm_parameter.mysql_root_password,
#   aws_iam_instance_profile.mysql
# ]
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
resource "aws_ssm_parameter" "mysql_root_password" {
  name  = "/${var.project}/${var.environment}/mysql_root_password"
  type  = "SecureString"
  value = "DevOps321"
  overwrite = true
}
resource "aws_instance" "catalogue" {
    ami           =   local.ami_id
    instance_type = "t3.micro"
    subnet_id = local.private_subnet_ids
    vpc_security_group_ids = [local.catalogue_sg_id]
    tags = merge(
        {
            Name = "${var.project}-${var.environment}-catalogue"
        },
        local.common_tags
    )
    }
resource "terraform_data" "bootstrap-catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id,
  ]
depends_on = [
  terraform_data.bootstrap-mongodb,
  terraform_data.bootstrap-redis
]
connection {
      type        = "ssh"
      host        = aws_instance.catalogue.private_ip
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
      "sudo /tmp/bootstrap.sh catalogue"
    ]
  }
}

resource "aws_instance" "cart" {
    ami           =   local.ami_id
    instance_type = "t3.micro"
    subnet_id = local.private_subnet_ids
    vpc_security_group_ids = [local.cart_sg_id]
    tags = merge(
        {
            Name = "${var.project}-${var.environment}-cart"
        },
        local.common_tags
    )
    }
resource "terraform_data" "bootstrap-cart" {
  triggers_replace = [
    aws_instance.cart.id,
  ]
depends_on = [
  terraform_data.bootstrap-redis
]
connection {
      type        = "ssh"
      host        = aws_instance.cart.private_ip
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
      "sudo /tmp/bootstrap.sh cart"
    ]
  }
}

resource "aws_instance" "user" {
    ami           =   local.ami_id
    instance_type = "t3.micro"
    subnet_id = local.private_subnet_ids
    vpc_security_group_ids = [local.user_sg_id]
    tags = merge(
        {
            Name = "${var.project}-${var.environment}-user"
        },
        local.common_tags
    )
    }
resource "terraform_data" "bootstrap-user" {
  triggers_replace = [
    aws_instance.user.id,
  ]
depends_on = [
  terraform_data.bootstrap-mongodb,
  terraform_data.bootstrap-redis
]
connection {
      type        = "ssh"
      host        = aws_instance.user.private_ip
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
      "sudo /tmp/bootstrap.sh user"
    ]
  }
}

resource "aws_instance" "shipping" {
    ami           =   local.ami_id
    instance_type = "t3.micro"
    subnet_id = local.private_subnet_ids
    vpc_security_group_ids = [local.shipping_sg_id]
    tags = merge(
        {
            Name = "${var.project}-${var.environment}-shipping"
        },
        local.common_tags
    )
    }
resource "terraform_data" "bootstrap-shipping" {
  triggers_replace = [
    aws_instance.shipping.id,
  ]
depends_on = [
  terraform_data.bootstrap-mysql
]
connection {
      type        = "ssh"
      host        = aws_instance.shipping.private_ip
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
      "sudo /tmp/bootstrap.sh shipping"
    ]
  }
}

resource "aws_instance" "frontend" {
    ami           =   local.ami_id
    instance_type = "t3.micro"
    subnet_id = local.public_subnet_ids
    vpc_security_group_ids = [local.frontend_sg_id]
    tags = merge(
        {
            Name = "${var.project}-${var.environment}-frontend"
        },
        local.common_tags
    )
    }
resource "terraform_data" "bootstrap-frontend" {
  triggers_replace = [
    aws_instance.frontend.id,
  ]
depends_on = [
  terraform_data.bootstrap-catalogue,
  terraform_data.bootstrap-cart,
  terraform_data.bootstrap-user,
  terraform_data.bootstrap-shipping,
  terraform_data.bootstrap-payment
]
connection {
      type        = "ssh"
      host        = aws_instance.frontend.private_ip
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
      "sudo /tmp/bootstrap.sh frontend"
    ]
  }
}

resource "aws_instance" "payment" {
    ami           =   local.ami_id
    instance_type = "t3.micro"
    subnet_id = local.private_subnet_ids
    vpc_security_group_ids = [local.payment_sg_id]
    tags = merge(
        {
            Name = "${var.project}-${var.environment}-payment"
        },
        local.common_tags
    )
    }
resource "terraform_data" "bootstrap-payment" {
  triggers_replace = [
    aws_instance.payment.id,
  ]
depends_on = [
  terraform_data.bootstrap-rabbitmq
]
connection {
      type        = "ssh"
      host        = aws_instance.payment.private_ip
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
      "sudo /tmp/bootstrap.sh payment"
    ]
  }
}
