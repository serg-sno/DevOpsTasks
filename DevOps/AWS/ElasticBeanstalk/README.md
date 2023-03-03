# AWS Cloudformation template that creates Elastic Beanstalk infrastructure, RDS database and CI/CD pipeline for Java Spring Boot Web application deployment
This is an example of a simple Java Spring Boot application with AWS Cloudformation IaaC template for fully automated infrastructure and CI/CD pipeline creation for Elastic Beanstalk deployment. RDS  database (PostgreSQL) is being created outside the Elastic Beanstalk environment. Managed IAM policies contain least-privelege permissions. Template is suitable for creating multiple Elastic Beanstalk environments for the same application.

## The description of Infrastructure and used AWS services
The following diagram illustrates the solution architecture and used AWS services:
![image](https://user-images.githubusercontent.com/105599883/215538710-8bf1233e-3340-4992-b828-0089bf0670df.png)
\* Single DB instance deployment option is used to fit Free Tier requirements, but you can easily change the template for your needs.

### Infrastructure includes
* Network layer
  * Public VPC - for Elastic Beanstalk EC2 Instances with two subnets (one for each AZ) and Internet Gateway
  * Database VPC - for RDS Postgres database with two subnets (one for each AZ)
  * VPC Peering - connects Public and Database VPCs
  * Route tables
* RDS Database (Postgres) - is created separately from Elastic Beanstalk environment
* Elastic Beanstalk environment

### Used AWS services
* AWS Elastic Beanstalk - Web application tier
* Amazon RDS - PostgreSQL
* AWS Certificate Manager - stores certificate for HTTPS connection (Optional, see [SSLCertificateArnParameter](#SSLCertificateArnParameter))
* AWS CodePipeline - orchestrates CI/CD process using source code stored in GitHub
* AWS CodeBuild - builds and tests sources
* Amazon SNS - is used for CI/CD event notifications (Optional, see [NotificationSNSTopicArnParameter](#NotificationSNSTopicArnParameter))
* AWS System Manager Parameter Store - securely stores parameters to establish database connection (URL, Username, Password)

## CI/CD pipeline description
The AWS CodePipeline is used to create CI/CD pipeline, it contains the following stages: 
* Source stage - CodeStarSourceConnection is used to trigger a pipeline when a new commit is made on a GitHub source code repository. The source action retrieves code changes when a pipeline is manually run or when a webhook event is sent from GitHub.
* Build stage - CodeBuild is used for building sources and running JUnits tests. A temporary PostgreSQL database is created in the build environment for integration testing.
* Approval stage - is used for manual approval before deployment.
* Deploy - deploys a new version of the application to Elastic Beanstalk Environment. Rolling deployment policy with 50% batch size is used.

## CloudFormation stacks description
The following diagram illustrates the structure of AWS CloudFormation stacks:
![image](https://user-images.githubusercontent.com/105599883/215747751-81f50c9c-9303-4efd-8b3b-4ef22ab07746.png)

### <a name="ParametersDescription">Template parameters description</a>
Root template RootCf.yml is located in /DevOpsTasks/DevOps/AWS/ElasticBeanstalk directory and has the following parameters:
* EnvironmentParameter - environment's name can be "prod" or "stage". If you need an additional environment, you must add a corresponding Spring Boot profile in the src/resources directory, because this parameter is used for activating the corresponding Spring Boot profile. Mandatory, default value is "prod".
* EC2InstanceTypeParameter - EC2 Instance type. Mandatory, default value is "t2.micro".
* DbInstanceTypeParameter - RDS Database instance type. Mandatory, default value is "db.t3.micro".
* CreateElasticBeanstalkApplication - the need to create Elastic Beanstalk Application. Select "No" if you create a second environment in already existing Elastic Beanstalk Application, otherwise select "Yes". Mandatory, default value is "Yes".
* GitHubConnectionParameter - ARN of GitHub repository connection. You must create a GitHub connection before running the AWS CloudFormation Stacks creation (See [GitHub connections](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-github.html)). Mandatory, default value is none.
* GitHubFullRepositoryIdParameter - repository id in your GitHub account. Mandatory, default value is none.
* GitHubBranchNameParameter - GitHub branch name, that will trigger the pipeline. Mandatory, default value is "main".
* <a name="NotificationSNSTopicArnParameter">NotificationSNSTopicArnParameter</a> - ARN of SNS topic for sending CI/CD notifications. If not set then notifications will not be sent. Optional, default value is "".
* <a name="SSLCertificateArnParameter">SSLCertificateArnParameter</a> - ARN of SSL certificate for HTTPS. If not set then HTTP will be used for Web Server connection. Optional, default value is "".

## How to use this application
1. Create a Fork of this repository in your GitHub account 
2. Clone your repository locally on a workstation
3. Install and configure AWS CLI on a workstation (see [Installing or updating the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
4. Create two parameters in AWS Systems Manager Parameter Store (replace "prod" in Name with actual environment name if another environment is used):
    * Username for creating RDS Database.
    Type: String
    Name: /config/DevOpsTasks_prod/db.username
    Value: any username, for example "postgres"
    * UserPassword for creating RDS Database
    Type: SecureString
    Name: /config/DevOpsTasks_prod/db.username
    Value: any password, for example "mysecretpas"
5. Create a GitHub repository connection (See [GitHub connections](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-github.html))
6. Create Cloudformation package using AWS CLI command.
    Change the current directory to /DevOpsTasks/DevOps/ElasticBeanstalk and run the command:
    ```
    aws cloudformation package --template-file RootCf.yml --s3-bucket <NAME_OF_S3_BUCKET> --output-template-file RootCf.cfpkg
    ```
    NAME_OF_S3_BUCKET - the name of existing S3 bucket where package files will be stored
7. Open the AWS CloudFormation console, click "Create stack" -> "With new resources (standard)", select "Template is ready", "Upload a template", "Choose file" and select RootCf.cfpkg, click "Next"
8. Set the parameter values. You could see a description of all parameters in this [section](#ParametersDescription). Most of them have default values. You must specify the following mandatory parameters:
    - Stack name, for example, "DevOpsTasksProd"
    - GitHubFullRepositoryIdParameter
    - GitHubConnectionParameter - ARN of GitHub repository connection, created in step 5
    
    Then click "Next" and "Next"
9. Check two checkboxes in the "Capabilities" section at the bottom of the page and click "Submit"
10. Now all resources are being created. You can see the creation progress in the Event tab of the CloudFormation Stack detail
11. After all stacks have been created, CodePipeline will be triggered. You can see CI/CD build and test logs in CodeBuild details on the Build step of the pipeline. The pipeline will be stopped on the approval step. After that, you need manually approve deployment in the AWS CodePipeline console.
12. After the deployment has been completed, open the Elastic Beanstalk console, find the new environment and open the URL. You should see the application's home page:

![image](https://user-images.githubusercontent.com/105599883/216605416-b30154de-7f8b-4f3f-b160-1eeca0273ebf.png)

## Clean up process
AWS CloudFormation doesn't automatically remove all types of created resources. You should delete RDS Database and clean S3 Bucket which stores CI/CD artifacts manually. You can find these resources by Tag Application='DevOpsTasks' or following the links in the "Resources" tabs of nested Database and CI/CD stacks. After that, you can delete the root stack.
