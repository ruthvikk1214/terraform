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

resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped"
  depends_on  = [terraform_data.catalogue]
}

resource "aws_ami_from_instance" "catalogue" {
  source_instance_id = aws_instance.catalogue.id
  name               = "${var.project}-${var.environment}-catalogue"
  depends_on         = [aws_ec2_instance_state.catalogue]
  tags = merge(
    {
      Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )
}

resource "aws_lb_target_group" "catalogue" {
  name                 = "${var.project}-${var.environment}-catalogue"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = local.vpc_id
  deregistration_delay = 60
  health_check {
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    matcher             = "200-299"
  }
}

resource "aws_launch_template" "catalogue" {
  name                                 = "${var.project}-${var.environment}-catalogue"
  instance_initiated_shutdown_behavior = "terminate"
  image_id                             = aws_ami_from_instance.catalogue.id
  instance_type                        = "t3.micro"
  vpc_security_group_ids               = [local.catalogue_sg_id]
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name = "${var.project}-${var.environment}-catalogue"
      },
      local.common_tags
    )
  }
}

resource "aws_autoscaling_group" "catalogue" {
  name                = "${var.project}-${var.environment}-catalogue"
  vpc_zone_identifier = local.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.catalogue.arn]
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  
  launch_template {
    id      = aws_launch_template.catalogue.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(
      {
        Name = "${var.project}-${var.environment}-catalogue"
      },
      local.common_tags
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

