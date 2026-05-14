#!/bin/bash
set -xe

# Install Terraform
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum install -y terraform

# Install Ansible
yum install -y ansible

# Verify
terraform version > /tmp/terraform_version.txt
ansible --version > /tmp/ansible_version.txt