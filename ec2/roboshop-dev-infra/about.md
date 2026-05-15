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