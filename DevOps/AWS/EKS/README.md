# Terraform templates for fully automated (IaaC) creation of AWS EKS cluster with private worker nodes, RDS database and CI/CD pipeline for Java Spring Boot Web application deployment
This is an example of a simple Java Spring Boot application with Terraform IaaC templates for fully automated infrastructure and CI/CD pipeline creation for Elastic Kubernetes Service (EKS) deployment. RDS  database (PostgreSQL) is being created in a private subnet of a separate VPC. Managed IAM policies contain least-privelege permissions.

***
> **_Caution:_** Created resources are not fully covered by the AWS free tier (e.g. EKS cluster and NAT Gateways). You need to pay some amount of money for this deployment.
***

## The description of Infrastructure and used AWS services
The following diagram illustrates the solution architecture and used AWS services:
![image](https://user-images.githubusercontent.com/105599883/222498343-6f213be9-0de5-41be-b807-3767f0e2d984.png)
\* Single DB instance deployment option is used to fit Free Tier requirements, but you can easily change the template for your needs.

### Infrastructure includes
* Network layer
  * EKS VPC - for EKS worker nodes, contains public and private subnets
  * Database VPC - for RDS Postgres database with two subnets (one for each AZ)
  * VPC Peering - connects Public and Database VPCs
  * Route tables
* RDS Database (Postgres)
* EKS Cluster with public and private node groups and AWS load balancer controller for managing the Application load balancer for accessing the application from the internet. Application pods are deployed in private nodes.
* ECR repository - for storing application docker images
* S3 Bucket - for CI/CD artifacts storing

### Used AWS services
* Amazon Elastic Kubernetes Service (EKS)
* Amazon RDS - PostgreSQL
* AWS CodePipeline - orchestrates CI/CD process using source code stored in GitHub
* AWS CodeBuild - builds and tests sources, builds and deploys docker image
* AWS System Manager Parameter Store - securely stores parameters to establish database connection (URL, Username, Password)

## CI/CD pipeline description
The AWS CodePipeline is used to create CI/CD pipeline, it contains the following stages: 
* Source stage - CodeStarSourceConnection is used to trigger a pipeline when a new commit is made on a GitHub source code repository. The source action retrieves code changes when a pipeline is manually run or when a webhook event is sent from GitHub.
* Build stage - CodeBuild is used for building sources and running JUnits tests. A temporary PostgreSQL database is created in the build environment for integration testing. If tests are passed it will build a docker image and put the image in ECR repository.
* Deploy stage - deploys a new docker image to the Amazon Elastic Kubernetes Service (EKS) using Helm.

## Terraform projects description
This solution contains three Terraform projects (located in DevOps/AWS/EKS/Terraform/):
* Infrastructure - creates all infrastructure resources including EKS Cluster
* AWS Load Balancer Controller - installs Load Balancer Controller to EKS for managing Application Load Balancer
* CICD - creates Code Build projects and CI/CD pipeline using CodePipeline

## How to deploy this solution
1. Create a Fork of this repository in your GitHub account 
2. Clone your repository locally on the workstation
3. Install and configure AWS CLI on the workstation (see [Installing or updating the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
4. Install kubectl on the workstation (see [Install Tools](https://kubernetes.io/docs/tasks/tools/))
5. Install Helm on the workstation (see [Installing Helm](https://helm.sh/docs/intro/install/))
6. Create two parameters in AWS Systems Manager Parameter Store:
    * Username for creating RDS Database.
    Type: String
    Name: /config/DevOpsTasks_prod/db.username
    Value: any username, for example "postgres"
    * UserPassword for creating RDS Database
    Type: SecureString
    Name: /config/DevOpsTasks_prod/db.username
    Value: any password, for example "mysecretpas"
7. Create a GitHub repository connection (See [GitHub connections](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-github.html))
8. Set git_hub_repository_id and git_hub_connection_arn parameters in DevOps/AWS/EKS/Terraform/CICD/terraform.tfvars
9. By default, deployment is using the "eu-central-1" AWS region. If you need to use another region you should change aws_region variables in terraform.tfvars files in all three terraform projects located at DevOps/AWS/EKS/Terraform/
10. Run DevOps/AWS/EKS/deploy.sh script
11. After script execution, CodePipeline will be triggered. You can see CI/CD building and testing logs in CodeBuild details on the Build step of the pipeline.
12. After the deployment has been completed, find the newly created Application Load Balancer and open its URL. You should see the application's home page:

![image](https://user-images.githubusercontent.com/105599883/216605416-b30154de-7f8b-4f3f-b160-1eeca0273ebf.png)

## Cleaning up process
Removing S3 buckets with content is prohibited by AWS. You should empty S3 Bucket which stores CI/CD artifacts manually (it is named like "DevOpsTasks-prod-artifacts-%") and then run DevOps/AWS/EKS/cleanup.sh script.
