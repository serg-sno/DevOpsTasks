# Example of a CI/CD pipeline as code with Jenkins using Maven, Docker pipeline, and Ansible plugins for Java Spring Boot application deployment.
This solution includes Terraform IaC templates for fully automated infrastructure creation. Web server's EC2 instances and RDS  database (PostgreSQL) are being created in private subnets of separate VPCs. Managed IAM roles contain least-privelege permissions. Jenkins is used for implementing CI/CD pipeline, it needs some additional settings described in the "Deployment and cleanup process" section.

***
> **_Caution:_** Created resources are not fully covered by the AWS free tier (e.g. t3.small EC2 instance for Jenkins and NAT Gateways). You need to pay some amount of money for this deployment.
***

## The description of Infrastructure and used AWS services
The following diagram illustrates the solution architecture and used AWS services:
![image](https://user-images.githubusercontent.com/105599883/226913919-9bdf1689-1bf8-423a-b0d7-15fad33b5139.png)
\* Single DB instance deployment option is used to fit Free Tier requirements, but you can easily change the template for your needs.

### Infrastructure includes
* Network layer
  * EC2 VPC - for EC2 web servers and Jenkins instances, contains public and private subnets
  * Database VPC - for RDS Postgres database with two subnets (one for each AZ)
  * VPC Peering - connects EC2 and Database VPCs
  * Route tables
  * Network load balancer
  * NAT Gateways
* RDS Database (Postgres)
* Web server EC2 instances in private subnet
* Jenkins server EC2 instance in public subnet

### Used services
* EC2
* Amazon RDS - PostgreSQL
* AWS System Manager Parameter Store - securely stores parameters to establish database connection (URL, Username, Password)

## CI/CD pipeline description
The Jenkins pipeline is used to create CI/CD pipeline and contains the following stages:
Source stage - GitHub triggers the Jenkins pipeline over webhook when a new commit is made on a GitHub source code repository. Jenkins retrieves code changes when the pipeline is manually run or when a webhook event is sent from GitHub.
Build stage - Maven plugin is used for building sources.
Test stage - Maven plugin runs JUnits tests. A Docker container with a temporary PostgreSQL database is being run in the test environment for integration testing. If tests are passed, the Deploy stage will be run.
Deploy stage - Ansible plugin is used for rolling deployment of the application to the web servers and restarting the services. Ansible uses AWS Dynamic Inventory Plugin to discover web servers' IP addresses.
CI/CD diagram:
![image](https://user-images.githubusercontent.com/105599883/226919580-dac1e97b-4771-4d1d-9689-391c26f55691.png)

## Deployment and cleanup process
The deployment and cleanup process is located in a separate [document](Deployment%20instruction.pdf)
