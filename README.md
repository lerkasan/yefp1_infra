## Architecture Overview

This Terraform configuration sets up a comprehensive AWS infrastructure for a web application. The architecture includes the following components:

- **Networking**:
  - **VPC**: Creates a Virtual Private Cloud with a specified CIDR block.
  - **Subnets**: Configures both public and private subnets across multiple availability zones.
  - **Internet Gateway**: Enables internet access for resources in public subnets.
  - **NAT Gateways**: Allows instances in private subnets to access the internet securely.
  - **VPC Endpoints**: Establishes private connectivity to AWS services without using the public internet.

- **Security**:
  - **Security Groups**: Sets up security groups for EC2 instances, Load Balancer, RDS, ElastiCache, and VPC endpoints to control inbound and outbound traffic.
  - **IAM Roles and Policies**: Defines roles and permissions for AWS services and EC2 instances.

- **Compute**:
  - **Autoscaling Group**: Manages a group of EC2 instances that scale automatically based on demand.
  - **Launch Configuration**: Specifies the AMI, instance type, and startup scripts for EC2 instances.

- **Load Balancing**:
  - **Application Load Balancer (ALB)**: Distributes incoming application traffic across multiple EC2 instances.
  - **Target Groups**: Routes requests to one or more registered targets as part of an ALB.

- **Databases**:
  - **Amazon RDS**: Provides a managed relational database service (e.g., PostgreSQL, MySQL).
  - **Amazon ElastiCache**: Offers a managed in-memory data store or cache service (e.g., Redis).

- **Deployment**:
  - **AWS CodeDeploy**: Automates code deployments to EC2 instances.
  - **Integration with GitHub**: Facilitates continuous deployment from GitHub repositories.

- **Container Registry**:
  - **Amazon ECR**: Hosts private Docker repositories for container images.

- **Storage**:
  - **Amazon S3 Buckets**:
    - **Website Origin Bucket**: Stores static website content.
    - **Access Logs Bucket**: Collects access logs from ALB and CloudFront.

- **Content Delivery**:
  - **Amazon CloudFront**: Distributes content globally with low latency.
  - **Integration with S3 and WAF**: Enhances security and performance.

- **Secrets Management**:
  - **AWS Systems Manager Parameter Store**: Securely stores application secrets and configurations.
