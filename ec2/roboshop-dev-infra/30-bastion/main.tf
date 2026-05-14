    resource "aws_instance" "bastion" {
    ami           =   local.ami_id
    instance_type = "t3.micro"
    subnet_id = local.public_subnet_ids
     user_data = file("bastion.sh")
     user_data_replace_on_change = true
    vpc_security_group_ids = [local.bastion_sg_id]
    iam_instance_profile = aws_iam_instance_profile.bastion.name
    
    
    root_block_device {
      volume_size = 50
      volume_type = "gp3"
      tags = merge(
        {
            Name = "${var.project}-${var.environment}-diskaddition"
        },
        local.common_tags
    )
    }
    tags = merge(
        {
            Name = "${var.project}-${var.environment}-bastion"
        },
        local.common_tags
    )
# provisioner "remote-exec" {
#     inline = [
#       "sudo yum install -y yum-utils",
#       "sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo",
#       "sudo yum -y install terraform", 
#       "sudo dnf install ansible -y "
#     ]
#     connection {
#       type        = "ssh"
#       host        = aws_instance.bastion.public_ip
#       user        = "ec2-user"
#       password = "DevOps321"
#   }
#   }
    }

    resource "aws_iam_role" "bastion" {
  name = "bastion"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
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

  tags = {
    tag-key = "tag-value"
  }
}
resource "aws_iam_role_policy_attachment" "bastion" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
# Grant SSM Read Access so Terraform can fetch IDs
resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}
resource "aws_iam_role_policy_attachment" "bastion_s3" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess" 
}
resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project}-${var.environment}-bastion"
  role = aws_iam_role.bastion.name
}
