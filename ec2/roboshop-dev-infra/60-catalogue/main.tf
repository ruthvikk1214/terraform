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
  protocol             = http
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
  name                      = "${var.project}-${var.environment}-catalogue"
  vpc_zone_identifier       = local.private_subnet_ids
  target_group_arns         = [aws_lb_target_group.catalogue.arn]
  min_size                  = 1
  max_size                  = 10
  desired_capacity          = 1
  force_delete              = false
  health_check_grace_period = 120
  health_check_type         = "ELB"
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  timeouts {
    delete = "15m"
  }
  launch_template {
    id      = aws_launch_template.catalogue.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-catalogue"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "catalogue_scale_up" {
  name                   = "${var.project}-${var.environment}-catalogue-scale-up"
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
resource "aws_alb_listener_rule" "catalogue" {
  listener_arn = local.backend_alb_listener_arn
  priority     = 10
  condition {
    host_header {
      values = ["catalogue.backend-alb-${var.environment}.${var.domain_name}"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }
}

resource "terraform_data" "catalogue-delete" {
  triggers_replace = [
    aws_instance.catalogue.id,
  ]
  depends_on = [aws_autoscaling_group.catalogue]
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.catalogue.id}"
  }
}
