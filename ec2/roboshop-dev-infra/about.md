PROJECT CONTEXT — ROBO SHOP DEV INFRA

I am building a full Roboshop infrastructure on AWS using Terraform + Ansible.

ENVIRONMENT
project = roboshop
environment = dev
region = us-east-1

MY DOMAIN
rk1214.in

NOT
daws88s.online

Trainer originally used daws88s.online, which caused DNS mismatch issues.

====================================================
ARCHITECTURE
====================================================

VPC layout:
- 1 VPC
- Public subnets
- Private subnets
- Database subnets

Instances:

PUBLIC
- bastion

PRIVATE
- frontend
- cart
- catalogue
- user
- shipping
- payment

DATABASE SUBNET
- mongodb
- redis
- mysql
- rabbitmq

====================================================
TERRAFORM FOLDER STRUCTURE
====================================================

00-vpc
10-sg
20-sg-rules
30-bastion
40-databases

====================================================
SECURITY GROUP DESIGN
====================================================

Security groups created via reusable module using for_each.

SG names:
- bastion
- mongodb
- redis
- mysql
- rabbitmq
- catalogue
- user
- cart
- shipping
- payment
- frontend

Because SG module outputs map objects, I previously got errors like:

"Incorrect attribute value type"
"object with 9 attributes"

Meaning object was passed instead of SG ID string.

====================================================
SUBNET ID FIX
====================================================

SSM parameters return comma-separated strings.

BAD:
database_subnet_ids = split(",", data.aws_ssm_parameter.database_subnet_ids.value)

GOOD:
database_subnet_ids = split(",", data.aws_ssm_parameter.database_subnet_ids.value)[0]
private_subnet_ids  = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
public_subnet_ids   = split(",", data.aws_ssm_parameter.public_subnet_ids.value)[0]

Because EC2 subnet_id expects a single string.

====================================================
BASTION
====================================================

Bastion exists in 30-bastion.

Used for:
- SSH access
- Terraform execution
- Ansible provisioning

IAM policies attached:
- AmazonEC2FullAccess
- AmazonSSMReadOnlyAccess
- AmazonS3FullAccess
- IAMFullAccess

IAMFullAccess was required because Terraform running from bastion needed permission to create:
- aws_iam_role
- aws_iam_instance_profile
- aws_iam_role_policy_attachment

====================================================
BASTION USER DATA
====================================================

Working bastion.sh:

#!/bin/bash
set -xe

yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum install -y terraform
yum install -y ansible

Terraform:
user_data = file("${path.module}/bastion.sh")

To rerun user_data:
terraform apply -replace=aws_instance.bastion

====================================================
SSH DESIGN
====================================================

Terraform runs from bastion.

Private instances are accessed via private IP, NOT public IP.

Example:
connection {
  type     = "ssh"
  host     = aws_instance.catalogue.private_ip
  user     = "ec2-user"
  password = "DevOps321"
}

SSH user:
ec2-user

SSH password:
DevOps321

====================================================
SECURITY GROUP RULES
====================================================

Internet to bastion:
Port 22
Source = my public IP (/32)

Private SSH from bastion:
Port 22
Source security group = bastion SG

Applied to:
- frontend
- payment
- catalogue
- cart
- user
- shipping
- mysql
- mongodb
- redis
- rabbitmq

App traffic:

REDIS
catalogue -> redis
user -> redis
cart -> redis
bastion -> redis

MONGODB
catalogue -> mongodb
user -> mongodb
bastion -> mongodb

MYSQL
shipping -> mysql
bastion -> mysql

RABBITMQ
payment -> rabbitmq
bastion -> rabbitmq

====================================================
BOOTSTRAP DESIGN
====================================================

40-databases uses terraform_data with:
- file provisioner
- remote-exec provisioner

Flow:
1. Copy bootstrap.sh
2. chmod +x
3. execute with component name

Example:
sudo /tmp/bootstrap.sh catalogue

====================================================
BOOTSTRAP SCRIPT
====================================================

#!/bin/bash
component=$1

dnf install ansible -y
cd /home/ec2-user
git clone https://github.com/ruthvikk1214/roboshop-ansible-roles-tf.git
cd roboshop-ansible-roles-tf/ansible-roboshop-roles-tf
ansible-playbook -e component=$component roboshop.yaml

====================================================
ANSIBLE REPO
====================================================

Repo:
roboshop-ansible-roles-tf

Contains:
- roles/
- group_vars/
- inventory.ini
- roboshop.yaml

Dynamic playbook:
- name: "configure {{ component }} server"
  hosts: "{{ component }}"
  become: yes
  roles:
    - "{{ component }}"

====================================================
DOMAIN ISSUE
====================================================

Critical bug:
Terraform created Route53 DNS records in:
rk1214.in

But Ansible expected:
daws88s.online

This caused:
MongoNetworkError: getaddrinfo ENOTFOUND mongodb-dev.daws88s.online

Fix:
Update Ansible group_vars/all.yaml

Change:
domain: daws88s.online

To:
domain: rk1214.in

====================================================
ROUTE53
====================================================

Terraform records:
- aws_route53_record.mongodb
- aws_route53_record.redis

Recreate:
terraform apply \
  -replace=aws_route53_record.mongodb \
  -replace=aws_route53_record.redis \
  -auto-approve

====================================================
MYSQL ISSUE
====================================================

MySQL role uses SSM parameter:
 /roboshop/dev/mysql_root_password

Error:
Failed to find SSM parameter

Fix:
aws ssm put-parameter \
  --name "/roboshop/dev/mysql_root_password" \
  --value "DevOps321" \
  --type SecureString \
  --overwrite \
  --region us-east-1

====================================================
MYSQL IAM FIX
====================================================

MySQL needs IAM role + instance profile so Ansible can read SSM.

Resources:
- aws_iam_role.mysql
- aws_iam_role_policy_attachment.mysql_ssm
- aws_iam_instance_profile.mysql

EC2:
iam_instance_profile = aws_iam_instance_profile.mysql.name

====================================================
DEPENDENCY RULES
====================================================

Catalogue depends on:
- aws_route53_record.mongodb
- terraform_data.bootstrap-mongodb

Cart depends on:
- terraform_data.bootstrap-redis

User depends on:
- terraform_data.bootstrap-mongodb
- terraform_data.bootstrap-redis

Shipping depends on:
- terraform_data.bootstrap-mysql

Payment depends on:
- terraform_data.bootstrap-rabbitmq

Frontend depends on backend apps.

This avoids race conditions.

====================================================
GIT FIXES
====================================================

Remote mismatch:
git remote set-url origin https://github.com/ruthvikk1214/<repo>.git

Push rejection:
git pull --rebase
git push

Nested repo warning happened because trainer repo with .git was copied inside another repo.

Fix:
remove inner .git directory

====================================================
CURRENT STATE
====================================================

Working:
- bastion
- mongodb
- redis
- rabbitmq
- payment

Previously failing:
- catalogue due to DNS mismatch
- mysql due to missing SSM password
- cart/user/shipping depending on earlier fixes

====================================================
IMPORTANT ASSUMPTIONS
====================================================

Terraform is run FROM bastion.
Ansible executes locally ON bastion.
Internal communication uses private IPs.
Route53 hosted zone is rk1214.in.
Trainer configs may still contain daws88s.online references.

Use this as persistent project memory for future troubleshooting.



# Configure one component at a time

terraform apply -replace=terraform_data.bootstrap-mongodb -auto-approve
terraform apply -replace=terraform_data.bootstrap-redis -auto-approve
terraform apply -replace=terraform_data.bootstrap-mysql -auto-approve
terraform apply -replace=terraform_data.bootstrap-rabbitmq -auto-approve
terraform apply -replace=terraform_data.bootstrap-catalogue -auto-approve
terraform apply -replace=terraform_data.bootstrap-user -auto-approve
terraform apply -replace=terraform_data.bootstrap-cart -auto-approve
terraform apply -replace=terraform_data.bootstrap-shipping -auto-approve
terraform apply -replace=terraform_data.bootstrap-payment -auto-approve
terraform apply -replace=terraform_data.bootstrap-frontend -auto-approve


# Recreate instance + rerun config (example format)

terraform apply \
  -replace=aws_instance.mongodb \
  -replace=terraform_data.bootstrap-mongodb \
  -auto-approve

terraform apply \
  -replace=aws_instance.redis \
  -replace=terraform_data.bootstrap-redis \
  -auto-approve

terraform apply \
  -replace=aws_instance.mysql \
  -replace=terraform_data.bootstrap-mysql \
  -auto-approve

terraform apply \
  -replace=aws_instance.rabbitmq \
  -replace=terraform_data.bootstrap-rabbitmq \
  -auto-approve

terraform apply \
  -replace=aws_instance.catalogue \
  -replace=terraform_data.bootstrap-catalogue \
  -auto-approve

terraform apply \
  -replace=aws_instance.user \
  -replace=terraform_data.bootstrap-user \
  -auto-approve

terraform apply \
  -replace=aws_instance.cart \
  -replace=terraform_data.bootstrap-cart \
  -auto-approve

terraform apply \
  -replace=aws_instance.shipping \
  -replace=terraform_data.bootstrap-shipping \
  -auto-approve

terraform apply \
  -replace=aws_instance.payment \
  -replace=terraform_data.bootstrap-payment \
  -auto-approve

terraform apply \
  -replace=aws_instance.frontend \
  -replace=terraform_data.bootstrap-frontend \
  -auto-approve

  ROBOSHOP TERRAFORM + ANSIBLE INFRA FIXES / FINAL NOTES

=========================================================
1. SUBNET ID FIX
=========================================================

Problem:
Terraform aws_instance.subnet_id expects a single subnet ID string, but SSM parameters returned comma-separated subnet lists.

Old:
database_subnet_ids = split(",", data.aws_ssm_parameter.database_subnet_ids.value)
private_subnet_ids  = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
public_subnet_ids   = split(",", data.aws_ssm_parameter.public_subnet_ids.value)

Fix:
database_subnet_ids = split(",", data.aws_ssm_parameter.database_subnet_ids.value)[0]
private_subnet_ids  = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
public_subnet_ids   = split(",", data.aws_ssm_parameter.public_subnet_ids.value)[0]

Reason:
aws_instance.subnet_id needs one subnet string, not a list.

=========================================================
2. SECURITY GROUP ID FIX
=========================================================

Problem:
Terraform complained:
Incorrect attribute value type
string required, but have object

Cause:
Security group locals were object references instead of SG ID strings.

Fix:
locals {
  bastion_sg_id   = data.aws_ssm_parameter.bastion_sg_id.value
  mongodb_sg_id   = data.aws_ssm_parameter.mongodb_sg_id.value
  catalogue_sg_id = data.aws_ssm_parameter.catalogue_sg_id.value
  redis_sg_id     = data.aws_ssm_parameter.redis_sg_id.value
  user_sg_id      = data.aws_ssm_parameter.user_sg_id.value
  cart_sg_id      = data.aws_ssm_parameter.cart_sg_id.value
  mysql_sg_id     = data.aws_ssm_parameter.mysql_sg_id.value
  shipping_sg_id  = data.aws_ssm_parameter.shipping_sg_id.value
  rabbitmq_sg_id  = data.aws_ssm_parameter.rabbitmq_sg_id.value
  payment_sg_id   = data.aws_ssm_parameter.payment_sg_id.value
  frontend_sg_id  = data.aws_ssm_parameter.frontend_sg_id.value
}

Reason:
aws_instance.vpc_security_group_ids requires string SG IDs.

=========================================================
3. BOOTSTRAP AUTOMATION ADDED
=========================================================

Added terraform_data bootstrap resources for:

- mongodb
- redis
- rabbitmq
- mysql
- catalogue
- cart
- user
- shipping
- payment
- frontend

Pattern:

resource "terraform_data" "bootstrap-<component>" {
  triggers_replace = [
    aws_instance.<component>.id
  ]

  connection {
    type     = "ssh"
    host     = aws_instance.<component>.private_ip
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
      "sudo /tmp/bootstrap.sh <component>"
    ]
  }
}

Reason:
Terraform creates EC2 → bootstrap script runs → Ansible configures component automatically.

=========================================================
4. BOOTSTRAP.SH FIX
=========================================================

Final bootstrap.sh:

#!/bin/bash
component=$1

dnf install ansible -y
cd /home/ec2-user
git clone https://github.com/ruthvikk1214/roboshop-ansible-roles-tf.git
cd roboshop-ansible-roles-tf
ansible-playbook -e component=$component roboshop.yaml

Fixes:
- proper argument passing
- correct repo URL
- correct folder path

=========================================================
5. DEPENDENCY ORDERING FIX
=========================================================

Catalogue:
depends_on = [
  terraform_data.bootstrap-mongodb,
  terraform_data.bootstrap-redis
]

Cart:
depends_on = [
  terraform_data.bootstrap-redis
]

User:
depends_on = [
  terraform_data.bootstrap-mongodb,
  terraform_data.bootstrap-redis
]

Shipping:
depends_on = [
  terraform_data.bootstrap-mysql
]

Payment:
depends_on = [
  terraform_data.bootstrap-rabbitmq
]

Frontend:
depends_on = [
  terraform_data.bootstrap-catalogue,
  terraform_data.bootstrap-cart,
  terraform_data.bootstrap-user,
  terraform_data.bootstrap-shipping,
  terraform_data.bootstrap-payment
]

Reason:
Prevents race conditions.

=========================================================
6. MYSQL IAM ROLE FIX
=========================================================

Created IAM role for MySQL instance.

resource "aws_iam_role" "mysql" {
  name = "mysql"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

Attached policy:

resource "aws_iam_role_policy_attachment" "mysql_ssm" {
  role       = aws_iam_role.mysql.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

Created profile:

resource "aws_iam_instance_profile" "mysql" {
  name = "mysql-instance-profile"
  role = aws_iam_role.mysql.name
}

Attached to EC2:

iam_instance_profile = aws_iam_instance_profile.mysql.name

Reason:
MySQL Ansible role reads password from SSM.

=========================================================
7. PERMANENT MYSQL PASSWORD FIX
=========================================================

Created Terraform-managed SSM parameter:

resource "aws_ssm_parameter" "mysql_root_password" {
  name      = "/${var.project}/${var.environment}/mysql_root_password"
  type      = "SecureString"
  value     = "DevOps321"
  overwrite = true
}

Reason:
Single source of truth.

=========================================================
8. MYSQL BOOTSTRAP DEPENDENCY FIX
=========================================================

Added:

depends_on = [
  aws_ssm_parameter.mysql_root_password,
  aws_iam_instance_profile.mysql
]

Reason:
Ensures password + IAM exist before MySQL bootstrap.

=========================================================
9. ANSIBLE MYSQL PASSWORD LOOKUP FIX
=========================================================

group_vars/all.yaml:

project: roboshop
env: dev
domain: rk1214.in

group_vars/mysql/vault.yaml:

MYSQL_ROOT_PASSWORD: "{{ lookup('amazon.aws.aws_ssm', '/%s/%s/mysql_root_password' | format(project, env), region='us-east-1', decrypt=True) }}"

Reason:
Reusable, cleaner lookup.

=========================================================
10. ROUTE53 FIX
=========================================================

Problem:
Used:

type = "NS"

Fix:
Use:

type = "A"

Reason:
Internal app hostnames must resolve to EC2 private IPs.

Examples:
mongodb-dev.rk1214.in
redis-dev.rk1214.in
mysql-dev.rk1214.in

Wrong NS records caused:
MongoNetworkError: getaddrinfo ENOTFOUND
SERVFAIL

=========================================================
11. BASTION SG ACCESS FIX
=========================================================

Added SG ingress rules so bastion can configure backend services.

Example:

resource "aws_security_group_rule" "redis_bastion" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.redis_sg_id
}

Same logic for:
- mongodb
- mysql
- rabbitmq
- app servers (SSH 22)

Reason:
Terraform runs from bastion and SSHs into private servers.

=========================================================
12. GIT FIXES
=========================================================

Fixed wrong remote:
git remote set-url origin https://github.com/ruthvikk1214/roboshop-ansible-roles-tf.git

Force push:
git push -u origin main --force

Fixed:
- wrong GitHub repo
- nested repo issue
- unrelated history conflict

=========================================================
13. DEBUGGING STRATEGY
=========================================================

Run one component at a time instead of full apply.

MySQL:
terraform apply -replace=terraform_data.bootstrap-mysql -auto-approve

Catalogue:
terraform apply -replace=terraform_data.bootstrap-catalogue -auto-approve

Shipping:
terraform apply -replace=terraform_data.bootstrap-shipping -auto-approve

Mongo Route53:
terraform apply -replace=aws_route53_record.mongodb -auto-approve

Reason:
Faster troubleshooting.

=========================================================
FINAL ARCHITECTURE
=========================================================

Provisioning flow:

Terraform
↓
Create EC2
↓
terraform_data bootstrap
↓
Copy bootstrap.sh
↓
Run bootstrap.sh
↓
Install Ansible
↓
Clone Ansible repo
↓
Run roboshop playbook

Application dependency flow:

SSM Password
↓
IAM Role/Profile
↓
Database Layer
(MongoDB / Redis / RabbitMQ / MySQL)
↓
Backend Services
(Catalogue / Cart / User / Shipping / Payment)
↓
Frontend

=========================================================
IMPORTANT FINAL CHECKS
=========================================================

✓ Route53 records must be type A
✓ MySQL password must come from Terraform-created SSM
✓ shipping depends on MySQL
✓ frontend depends on all backend services
✓ Terraform executed from bastion
✓ SG rules allow bastion SSH access
✓ bootstrap.sh uses correct repo

FINAL STATUS:
WORKING AUTOMATED ROBOSHOP INFRA