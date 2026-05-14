#!/bin/bash
set -xe

# Install Terraform
dnf install -y yum-utils
dnf-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
dnf install -y terraform

# Install Ansible
dnf install -y ansible

# Verify
terraform version > /tmp/terraform_version.txt
ansible --version > /tmp/ansible_version.txt