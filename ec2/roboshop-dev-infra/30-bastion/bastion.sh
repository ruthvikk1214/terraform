#! /bin/bash

#increasing the /home space 
# growpart /dev/nvme0n1 4
# lvextend -r -L +30GB /dev/mapper/RootVG-homeVol
# xfs_growfs /home

# 1. Install Terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform

# 2. Install Ansible
# Note: RHEL 9 requires the EPEL repository for Ansible
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
sudo dnf install ansible -y

# 3. Verify Installations
terraform -version
ansible --version 