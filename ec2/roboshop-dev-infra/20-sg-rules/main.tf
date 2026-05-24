# ==========================================
# BASTION SECURITY GROUP
# ==========================================
resource "aws_security_group_rule" "bastion_internet" { #bastion accepting connection from internet
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [local.my_ip]

  security_group_id = local.bastion_sg_id
}

# ==========================================
# MONGODB SECURITY GROUP
# ==========================================
resource "aws_security_group_rule" "mongodb_bastion" { #mongo accepting connection from bastion to configure mongodb
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.mongodb_sg_id
}

resource "aws_security_group_rule" "mongodb_catalogue" { #mongo accepting connection from catalogue to access products
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = local.catalogue_sg_id
  security_group_id        = local.mongodb_sg_id
}

resource "aws_security_group_rule" "mongodb_user" { #mongodb accepting connections from user service to fetch user information
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = local.user_sg_id
  security_group_id        = local.mongodb_sg_id
}

# ==========================================
# REDIS SECURITY GROUP
# ==========================================
resource "aws_security_group_rule" "redis_bastion" { #redis accepting connection from bastion to configure redis
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.redis_sg_id
}

resource "aws_security_group_rule" "redis_user" { #redis accepting connection from user to cache user information
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = local.user_sg_id
  security_group_id        = local.redis_sg_id
}

resource "aws_security_group_rule" "redis_cart" { #redis accepting connection from cart to fetch cart details
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = local.cart_sg_id
  security_group_id        = local.redis_sg_id
}

resource "aws_security_group_rule" "redis_catalogue" { #redis accepting connection from catalogue to fetch products
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = local.catalogue_sg_id
  security_group_id        = local.redis_sg_id
}

# ==========================================
# MYSQL SECURITY GROUP
# ==========================================
resource "aws_security_group_rule" "mysql_bastion" { #mysql accepting connections from bastion to configure mysql
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  # Where traffic is coming from
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.mysql_sg_id
}

resource "aws_security_group_rule" "mysql_shipping" { #mysql accepting connections from shipping to fetch shipping information
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = local.shipping_sg_id
  security_group_id        = local.mysql_sg_id
}

# ==========================================
# RABBITMQ SECURITY GROUP
# ==========================================
resource "aws_security_group_rule" "rabbitmq_bastion" { #rabbitmq accepting connections from bastion to configure rabbitmq
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  # Where traffic is coming from
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.rabbitmq_sg_id
}

resource "aws_security_group_rule" "rabbitmq_payment" { #rabbitmq accepting connections from payment to send messages
  type                     = "ingress"
  from_port                = 5672
  to_port                  = 5672
  protocol                 = "tcp"
  source_security_group_id = local.payment_sg_id
  security_group_id        = local.rabbitmq_sg_id
}

# ==========================================
# CATALOGUE SECURITY GROUP
# ==========================================
resource "aws_security_group_rule" "catalogue_bastion" { #catalogue accepting connections from bastion to configure catalogue
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  # Where traffic is coming from
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.catalogue_sg_id
}

resource "aws_security_group_rule" "catalogue_backend-alb" { #catalogue accepting connections from backend alb to serve requests
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = local.backend_alb_sg_id
  security_group_id        = local.catalogue_sg_id
}

# ==========================================
# USER SECURITY GROUP
# ==========================================
resource "aws_security_group_rule" "user_bastion" { #user accepting connections from bastion to configure user
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  # Where traffic is coming from
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.user_sg_id
}
resource "aws_security_group_rule" "user_backend-alb" { #user accepting connections from backend alb to serve requests
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = local.backend_alb_sg_id
  security_group_id        = local.user_sg_id
}
# ==========================================
# CART SECURITY GROUP
# ==========================================
resource "aws_security_group_rule" "cart_bastion" { #cart accepting connections from bastion to configure cart
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.cart_sg_id
}

resource "aws_security_group_rule" "cart_backend-alb" { #cart accepting connections from backend alb to serve requests
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = local.backend_alb_sg_id
  security_group_id        = local.cart_sg_id
}

# ==========================================
# SHIPPING SECURITY GROUP
# ==========================================
resource "aws_security_group_rule" "shipping_bastion" { #shipping accepting connections from bastion to configure shipping
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  # Where traffic is coming from
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.shipping_sg_id
}

resource "aws_security_group_rule" "shipping_backend-alb" { #shipping accepting connections from backend alb to serve requests
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = local.backend_alb_sg_id
  security_group_id        = local.shipping_sg_id
}

# ==========================================
# PAYMENT SECURITY GROUP
# ==========================================
resource "aws_security_group_rule" "payment_bastion" { #payment accepting connections from bastion to configure payment
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  # Where traffic is coming from
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.payment_sg_id
}

resource "aws_security_group_rule" "payment_backend-alb" { #payment accepting connections from backend alb to serve requests
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = local.backend_alb_sg_id
  security_group_id        = local.payment_sg_id
}

# ==========================================
# FRONTEND SECURITY GROUP
# ==========================================
resource "aws_security_group_rule" "frontend_bastion" { #frontend accepting connections from bastion to configure frontend
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.frontend_sg_id
}

resource "aws_security_group_rule" "frontend_frontend_alb" { #frontend accepting connections from frontend alb to serve requests
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.frontend_alb_sg_id
  security_group_id        = local.frontend_sg_id
}

# ==========================================
# BACKEND ALB SECURITY GROUP
# ==========================================
resource "aws_security_group_rule" "backend-alb_bastion" { #backend alb accepting connections from bastion to configure backend alb
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.backend_alb_sg_id
}


resource "aws_security_group_rule" "backend-alb_catalogue" { #backend alb accepting connections from catalogue to route requests
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.catalogue_sg_id
  security_group_id        = local.backend_alb_sg_id
}

resource "aws_security_group_rule" "backend-alb_user" { #backend alb accepting connections from user to route requests
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.user_sg_id
  security_group_id        = local.backend_alb_sg_id
}

resource "aws_security_group_rule" "backend-alb_cart" { #backend alb accepting connections from cart to route requests
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.cart_sg_id
  security_group_id        = local.backend_alb_sg_id
}

resource "aws_security_group_rule" "backend-alb_shipping" { #backend alb accepting connections from shipping to route requests
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.shipping_sg_id
  security_group_id        = local.backend_alb_sg_id
}

resource "aws_security_group_rule" "backend-alb_payment" { #backend alb accepting connections from payment to route requests
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.payment_sg_id
  security_group_id        = local.backend_alb_sg_id
}

resource "aws_security_group_rule" "backend-alb_frontend" { #backend alb accepting connections from frontend to route requests
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.frontend_sg_id
  security_group_id        = local.backend_alb_sg_id
}

# ==========================================
# FRONTEND ALB SECURITY GROUP
# ==========================================
resource "aws_security_group_rule" "frontend_alb_internet" { #frontend alb accepting connections from internet to serve requests
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = local.frontend_alb_sg_id
}

# ==========================================
# OPENVPN SECURITY GROUP
# ==========================================

resource "aws_security_group_rule" "openvpn_public_443" { #openvpn accepting connections from internet to serve requests
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = local.openvpn_sg_id
}
# ==========================================
# OPENVPN ADMIN UI SECURITY GROUP
# ==========================================
resource "aws_security_group_rule" "openvpn_public_943" { #openvpn accepting connections from internet to serve requests
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = local.openvpn_sg_id
}

resource "aws_security_group_rule" "openvpn_backend-alb_sg_id" { #openvpn accepting connections from backend alb
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.openvpn_sg_id
  security_group_id        = local.backend_alb_sg_id
}