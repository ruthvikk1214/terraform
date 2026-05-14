#!/bin/bash
set -xe

# Terraform
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum install -y terraform

# EPEL for Ansible
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

# Ansible
dnf install -y ansible

# Verification
terraform version > /tmp/terraform_version.txt
ansible --version > /tmp/ansible_version.txt