#!/bin/bash
component=$1
dnf install ansible -y 
cd /home/ec2-user
git clone https://github.com/ruthvikk1214/roboshop-ansible-roles-tf.git
cd roboshop-ansible-roles-tf
cd ansible-roboshop-roles-tf/
ansible-playbook -e "component=$component env=dev" roboshop.yaml