# Roboshop Infrastructure - Detailed Folder Breakdown

This document provides an elaborated explanation of each folder and its role within the Roboshop Terraform infrastructure located in `/home/ruthvekh/ruthvik/gitrepos/terraform/ec2/roboshop-dev-infra`.

---

## 1. `00-vpc` (Virtual Private Cloud)
This folder is the foundational layer. It sets up the underlying network where all other resources will be placed.

*   **What it does:** It provisions the AWS Virtual Private Cloud (VPC) network.
*   **Module usage:** It utilizes a custom local module `../../terraform-aws-vpc` rather than creating raw resources, ensuring a standardized network layout across potential multiple environments.
*   **Subnet Architecture:** It creates three specific tiers of subnets:
    *   **Public Subnets:** For internet-facing resources like the Bastion host and the Frontend.
    *   **Private Subnets:** For backend application servers (Catalogue, Cart, User, Shipping, Payment) that should not be directly accessible from the outside world.
    *   **Database Subnets:** For the data persistence layer (MongoDB, Redis, MySQL, RabbitMQ).
*   **State Management (`parameter.tf`):** Instead of relying solely on Terraform state outputs, it exports the newly created `vpc_id`, `public_subnet_ids`, `private_subnet_ids`, and `database_subnet_ids` directly into **AWS Systems Manager (SSM) Parameter Store**. This allows subsequent layers (like databases and apps) to simply look up the network details dynamically without needing to pass them as hardcoded variables.

---

## 2. `10-sg` (Security Groups)
This folder manages the "firewalls" for the instances but does *not* set the rules yet.

*   **What it does:** It creates the empty AWS Security Groups (SGs) for every single component in the architecture.
*   **Implementation (`main.tf`):** It loops (`for_each`) over a predefined list of SG names (e.g., `mongodb`, `redis`, `catalogue`, `frontend`, `bastion`) and calls a local module `../../terraform-aws-sg` to create them.
*   **State Management (`parameters.tf`):** Similar to the VPC folder, it takes the newly created Security Group IDs and exports them to the AWS SSM Parameter Store (e.g., `/{project}/{environment}/mongodb_sg_id`). This decouple the creation of SGs from their usage, avoiding circular dependencies.

---

## 3. `20-sg-rules` (Security Group Rules)
This folder defines the intricate web of permitted traffic flow between the Security Groups created in the previous step.

*   **What it does:** It adds `ingress` (incoming) rules to the Security Groups.
*   **Data Fetching (`data.tf` & `locals.tf`):** It fetches the Security Group IDs back out of the SSM Parameter Store that were written in `10-sg`.
*   **Traffic Flow Rules (`main.tf`):** It explicitly defines which component can talk to which component, implementing the principle of least privilege. Examples include:
    *   **Bastion Access:** The Bastion SG allows port 22 (SSH) from the administrator's IP. All other SGs (databases, apps) allow port 22 specifically *from* the Bastion SG.
    *   **Application to Database:** The MongoDB SG allows port 27017 from the Catalogue and User SGs. The MySQL SG allows port 3306 from the Shipping SG. The RabbitMQ SG allows port 5672 from the Payment SG.
    *   **Public Access:** The Frontend SG allows port 80 (HTTP) from anywhere (`0.0.0.0/0`).

---

## 4. `30-bastion` (Bastion Host)
This folder provisions the administrative entry point into the private network.

*   **What it does:** Creates an EC2 instance in the *public* subnet to serve as a jump box.
*   **IAM Role Management (`main.tf`):** Because Terraform and Ansible will be run *from* this bastion host to manage the rest of the infrastructure, it attaches a very powerful IAM Role to the instance. This role includes permissions like `AmazonEC2FullAccess`, `AmazonRoute53FullAccess`, `AmazonS3FullAccess`, `AmazonSSMFullAccess`, and `IAMFullAccess`.
*   **Bootstrapping (`bastion.sh`):** It uses `user_data` to automatically install required tools like `terraform` and `ansible` onto the bastion host right when it boots up.

---

## 5. `40-databases` (Databases & Applications)
Despite the name, this folder actually provisions *both* the databases and the backend application instances, handling their entire lifecycle.

*   **What it does:** Provisions the EC2 instances for MongoDB, Redis, MySQL, RabbitMQ, Catalogue, Cart, User, Shipping, Payment, and Frontend.
*   **Placement:** It automatically assigns them to their correct subnets (Database subnets for DBs, Private subnets for Apps, Public subnet for Frontend) and attaches the correct Security Groups by looking up the SSM parameters.
*   **Automated Configuration (Ansible Bootstrap):** Instead of just creating empty servers, it uses Terraform `terraform_data` resources combined with a `remote-exec` provisioner. 
    *   Once an instance spins up, Terraform SSHs into it (using the `ec2-user` and password).
    *   It copies over a `bootstrap.sh` script.
    *   It executes the script, which installs Ansible locally on the new instance, pulls down an Ansible playbook repository (`roboshop-ansible-roles-tf`), and runs the playbook to configure that specific component automatically.
*   **Dependency Management (`depends_on`):** To ensure Ansible configuration succeeds, it enforces strict creation orders. For example, the `catalogue` application will not begin its automated configuration until *after* the `mongodb` database has fully finished its setup.
*   **DNS Setup (`r53.tf`):** It creates internal Route53 `A` records (e.g., `mongodb-dev.rk1214.in`) pointing to the private IPs of the newly created instances, allowing applications to find their databases by name rather than hardcoded IP addresses.
*   **Secrets Management:** It specifically handles generating and storing the MySQL root password as a SecureString in the SSM Parameter Store and attaching an IAM role to the MySQL instance so Ansible can read it during configuration.
