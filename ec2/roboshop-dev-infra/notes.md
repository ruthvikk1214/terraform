# Roboshop Infrastructure - Detailed Folder Breakdown

This document provides an elaborated explanation of each folder and its role within the Roboshop Terraform infrastructure located in `/home/ruthvekh/ruthvik/gitrepos/terraform/ec2/roboshop-dev-infra`.

---

## 1. `00-vpc` (Virtual Private Cloud)
This folder is the foundational layer. It sets up the underlying network where all other resources will be placed.

*   **What it does:** It provisions the AWS Virtual Private Cloud (VPC) network.
*   **Module usage:** It utilizes a custom local module `../../terraform-aws-vpc` rather than creating raw resources, ensuring a standardized network layout across potential multiple environments.
*   **Subnet Architecture:** It creates three specific tiers of subnets:
    *   **Public Subnets:** For internet-facing resources like the Bastion host and the Frontend.
    *   **Private Subnets:** For backend application servers (Catalogue, Cart, User, Shipping, Payment) that should not be directly accessible from the outside world. **Note:** All instances deployed in these private subnets will securely access the internet for outbound requests (like downloading software packages or updates) using a **NAT Gateway** placed in the public subnet.
    *   **Database Subnets:** For the data persistence layer (MongoDB, Redis, MySQL, RabbitMQ). Similar to private subnets, any necessary outbound internet traffic from these databases routes through the NAT Gateway.
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

*   **What it does:** Creates an EC2 instance in the *public* subnet to serve as a jump host.
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

---

## 6. Load Balancer Concepts

### How Does a Load Balancer Work?
A Load Balancer acts as a "traffic cop" sitting in front of your servers and routing client requests across all servers capable of fulfilling those requests in a manner that maximizes speed and capacity utilization. 
*   **Distribution:** It distributes incoming network traffic across multiple targets (like EC2 instances, containers, or IP addresses).
*   **Health Checks:** It continuously monitors the health of its registered targets. If a target becomes unhealthy, the load balancer stops routing traffic to it and redirects it to the remaining healthy targets.
*   **Scaling:** It helps applications scale by easily allowing the addition or removal of backend servers without changing the endpoint that the clients use.
*   **Session Persistence:** (Optional) It can tie a user's session to a specific target to ensure all their requests go to the same server (sticky sessions).

### Sequence of Events When a Request Hits an Application Load Balancer (ALB)
Before a request reaches the backend servers, a specific sequence of events occurs:

1.  **DNS Resolution:**
    *   The user types a URL (e.g., `www.roboshop.com`) into their browser.
    *   The browser queries a DNS server (like Amazon Route 53) to resolve the domain name to an IP address.
    *   Route 53 returns the IP addresses of the ALB nodes (since ALBs are dynamically scaled by AWS, Route 53 returns a dynamic list of IPs).
2.  **TCP Handshake & TLS/SSL Termination:**
    *   The client establishes a TCP connection with one of the ALB nodes using the resolved IP.
    *   If using HTTPS, the ALB performs the TLS/SSL handshake. The ALB decrypts the request, offloading the CPU-intensive decryption process from the backend servers.
3.  **ALB Request Evaluation (Listener Rules):**
    *   The ALB evaluates the incoming HTTP/HTTPS request against its configured **Listeners**.
    *   It checks the **Listener Rules** based on the request's content, such as the Host header (e.g., `api.roboshop.com`) or the path (e.g., `/api/catalogue`).
4.  **Target Group Routing:**
    *   Based on the matching rule, the ALB determines which **Target Group** should handle the request.
    *   The Target Group contains a list of backend resources (e.g., EC2 instances running the catalogue service).
5.  **Target Selection:**
    *   The ALB selects a healthy target from the Target Group using a routing algorithm (typically Round Robin for ALBs).
6.  **Backend Connection:**
    *   The ALB opens a new TCP connection (or reuses an existing one) to the selected backend instance and forwards the HTTP request to it.
7.  **Response Handling:**
    *   The backend server processes the request and sends the HTTP response back to the ALB.
    *   The ALB forwards the response back to the client over the original connection.

### Important Port Numbers in an ALB Setup
When configuring an Application Load Balancer, you need to manage two sets of ports:

1. **Listener Ports (Front-End):**
   * These are the ports the ALB listens on for incoming traffic from clients (users or other services).
   * **Port 80 (HTTP):** Standard unencrypted web traffic.
   * **Port 443 (HTTPS):** Encrypted secure web traffic (requires an SSL/TLS certificate).

2. **Target Group Ports (Back-End):**
   * This is the port your actual application is running on inside the EC2 instances. The ALB forwards traffic to this port.
   * *Examples in Roboshop:*
     * **Port 80:** Used for the Nginx `frontend` service.
     * **Port 8080:** Used for the backend APIs like `catalogue`, `user`, `cart`, `shipping`, and `payment`.

3. **Health Check Ports:**
   * The ALB periodically pings a specific path (e.g., `/health`) on your instances to ensure they are alive. This usually defaults to the **Target Group Port** (e.g., 80 or 8080) unless explicitly configured otherwise.

4. **Complete List of Roboshop Ports:**
   Beyond the ALB itself, the various backend components use specific ports that must be permitted in your Security Group (`20-sg-rules`) configurations:
   * **Port 22:** SSH (used by the Bastion host to connect to all other instances).
   * **Port 80:** HTTP (Frontend Nginx server and ALB listener).
   * **Port 443:** HTTPS (Secure ALB listener).
   * **Port 8080:** Backend Application APIs (Catalogue, User, Cart, Shipping, Payment).
   * **Port 3306:** MySQL database.
   * **Port 27017:** MongoDB database.
   * **Port 6379:** Redis in-memory datastore.
   * **Port 5672:** RabbitMQ message broker.

### Why Use an ALB Instead of Multiple EC2 Instances with a Domain Name?
Using an Application Load Balancer (ALB) offers significant advantages over simply having multiple EC2 instances with a DNS record pointing to them:

1.  **High Availability & Fault Tolerance:**
    *   **ALB:** It automatically detects unhealthy instances and reroutes traffic to healthy ones.
    *   **No ALB:** If one instance fails, all traffic to that instance is lost until the instance is manually fixed or replaced. There is no automatic failover mechanism.

2.  **Scalability:**
    *   **ALB:** It can automatically scale the number of its own nodes to handle traffic spikes. You can also easily add or remove backend instances behind the ALB without changing the public DNS name.
    *   **No ALB:** Adding more instances requires manually updating DNS records and potentially configuring round-robin DNS, which is less efficient and not transparent to the user.

3.  **Security:**
    *   **ALB:** It can handle SSL/TLS termination, offloading the encryption overhead from your backend servers. It also provides features like Web Application Firewall (WAF) integration.
    *   **No ALB:** You would need to install SSL certificates on every single EC2 instance and manage their lifecycle individually.

4.  **Health Monitoring:**
    *   **ALB:** Provides deep, configurable health checks. It can check specific endpoints (e.g., `/health`) to determine if the application is truly responsive.
    *   **No ALB:** You can't easily perform health checks on individual instances via a simple domain name without extra configuration.

5.  **Simplified Client Management:**
    *   **ALB:** Clients only need to know one hostname. The ALB handles the complexity of routing to the correct backend instance.
    *   **No ALB:** Clients might need to be aware of multiple IP addresses, or you would need a more complex DNS setup to handle the distribution.

### Key Concepts in Application Load Balancing (ALB)
To effectively utilize ALBs in your infrastructure, it's crucial to understand these core concepts:

1. **ALB Nodes (Dynamic Instances):**
   * Unlike EC2 instances, an ALB is not a single server. It is a managed service by AWS that runs on multiple internal instances distributed across multiple Availability Zones.
   * AWS automatically provisions, manages, and scales the number of these nodes based on incoming traffic.
   * As traffic increases, AWS automatically adds more ALB nodes; as traffic subsides, it scales them down to save costs.
   * This inherent multi-AZ distribution provides high availability by default.

2. **Target Groups:**
   * A Target Group is a logical grouping of your backend resources (e.g., EC2 instances) that the ALB will route traffic to.
   * You can define health check parameters for each target group to specify how rigorously the ALB should test the health of the instances.
   * You can route traffic to different target groups based on rules (e.g., send `/api/*` traffic to one group and `/images/*` to another).

3. **Listeners:**
   * A Listener is a process that checks for connection requests. It has a protocol (e.g., HTTP, HTTPS) and a port (e.g., 80, 443).
   * The Listener is what clients connect to.
   * You can have multiple listeners for the same ALB (e.g., one for HTTP and another for HTTPS).
   * **Note:** An ALB can have multiple listeners, and each listener can have multiple rules. For example, a Listener for HTTPS (port 443) could have one rule to forward `/api/*` to the API Target Group and another rule to forward `/` to the Frontend Target Group.

4. **Listener Rules:**
   * Listener Rules define how the ALB should behave when a request matches specific criteria.
   * Rules are processed in order of priority, and the first rule that matches is applied.
   * You can use conditions based on host headers, URL paths, HTTP headers, source IP addresses, and more.
   * **Default Rule:** Every listener must have a default rule that applies if no other rules match.

5. **Health Checks:**
   * These are crucial for maintaining the availability of your application.
   * The ALB periodically sends requests to a specified path (the health check endpoint) on each target.
   * If a target fails a certain number of health checks, the ALB marks it as unhealthy and stops sending traffic to it.
   * Once the instance becomes healthy again (passes the checks), the ALB automatically resumes sending traffic to it.
   * Health checks help you meet the 99.95% availability SLA for ALB usage.

---

## 7. `60-catalogue` (Catalogue Component & AMI Baking Pattern)
This folder provisions the EC2 instance for the `catalogue` backend service and bakes it into a custom Amazon Machine Image (AMI).

*   **Subnet List vs. String Alignment:** 
    *   To prevent type/index errors, `locals.tf` fetches the comma-separated private subnets as a clean list using:
        ```terraform
        private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
        ```
    *   In `main.tf`, the first subnet is safely accessed using:
        ```terraform
        subnet_id = local.private_subnet_ids[0]
        ```
*   **Dynamic Data Sources (`data.tf`):** A dedicated data configuration resolves parameters dynamically, including the base `joindevops` AMI (`Redhat-9-DevOps-Practice`), `private_subnet_ids`, and the `catalogue_sg_id` from SSM Parameter Store.
*   **Automated Bootstrap and Baking Lifecycle:**
    1.  **Creation:** An EC2 instance `aws_instance.catalogue` is launched.
    2.  **Configuration:** The `terraform_data.catalogue` resource triggers, copies `bootstrap.sh`, and runs Ansible locally on the instance to configure it fully as the catalogue service.
    3.  **State Management (Stop):** The `aws_ec2_instance_state.catalogue` resource is defined to automatically change the instance state to `stopped` once the bootstrap process is successfully completed.
    4.  **Baking:** The `aws_ami_from_instance.catalogue` resource takes the stopped, fully bootstrapped instance and bakes it into a custom AMI named `${var.project}-${var.environment}-catalogue`.
    5.  **Benefit:** This pre-baked AMI can be used for zero-delay auto-scaling and immutable deployments, eliminating the need to run Ansible playbooks from scratch during scale-out events.