# Infrastructure for HTML Resume Project

## Project Overview
This repository contains the lambda function & Terraform code for deploying the infrastructure of the HTML resume project, hosted on AWS. The infrastructure includes an API for a visitor counter, storage for the HTML files, and secure DNS configuration.

## Related Repositories
- [Frontend Repository](https://github.com/DanielMode/CRCFackend): This repository contains the frontend code for a cloud-hosted HTML resume with a visitor counter.

## Architecture Overview
The project infrastructure includes:
- **AWS S3**: Hosts the HTML files for the resume and visitor counter.
- **CloudFront**: Caches and serves the content.
- **API Gateway**: Exposes an api endpoint for the visitor counter.
- **Lambda Function**: Handles visitor count updates and interacts with DynamoDB.
- **DynamoDB**: Stores visitor count data.
- **Route 53**: Manages DNS and custom domain routing.
- **Certificate Manager**: Provides an SSL/TLS certificate for secure access.

## Prerequisites
- AWS Account with permissions to provision resources (S3, CloudFront, API Gateway, Lambda, DynamoDB, Route 53, Certificate Manager).
- Registered Domain Name: Required for setting up DNS and custom domain routing in Route 53.
- AWS Resources:
   - S3 Buckets:
      - One bucket to store the Terraform state file.
      - A second bucket to store the zipped Lambda code.
   - DynamoDB Table: Used to manage Terraform state lock files, enabling safe and consistent state management during deployments.
- Terraform
- GitHub account with repository access

**Manual Setup Steps**

Before running Terraform, you’ll need to:

   - Create an S3 bucket for the Terraform state file and another for the zipped Lambda function.
   - Set up a DynamoDB table for state locking.
     
These resources should be configured manually through the AWS console.

## Installation and Setup
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/DanielMode/CRCBackend.git
   cd CRCBackend
2. **Initialize and Apply Terraform**:
   - Initialize Terraform:
     ```bash
     terraform init
   - Apply Configurations:
     ```bash
     terraform apply
3. **Link Frontend**: Once the infrastructure is set up, upload frontend files to the S3 bucket created.
4. **Set Up GitHub Actions**:
   Automated infrastructure deployment is managed with GitHub Actions. When changes are pushed to the main branch:
   - GitHub Actions authenticates with AWS using OIDC.
   - Terraform commands automatically provision and update resources in AWS.
   Refer to `.github/workflows/CI-CD.yml` for the full pipeline setup.

## Usage
Once deployed, visit the URL provided by the CloudFront distribution or Route 53 DNS to access the resume. The visitor counter will display the number of visits to the page.

## Troubleshooting
- OIDC Authentication Errors: Verify role configuration and permissions in AWS for GitHub Actions.
- Terraform Apply Issues: Review specific error messages, often caused by resource conflicts or permissions.

## Authentication with AWS SSO
This project uses AWS SSO (Single Sign-On) for secure access to AWS resources, avoiding the use of permanent IAM credentials. AWS SSO provides temporary access permissions, improving security.

If you are setting up the project independently, you’ll need to configure your own AWS SSO permissions accordingly.

## OIDC Authentication
GitHub Actions uses OIDC (OpenID Connect) to securely authenticate with AWS for automated deployments. This approach allows GitHub Actions to assume a role in AWS, eliminating the need for static AWS credentials stored in GitHub secrets.

**Key Points**:
- **Purpose**: OIDC enables secure, short-lived authentication between GitHub Actions and AWS for infrastructure provisioning.
- **AWS Role Setup**: An IAM role in AWS is configured to trust GitHub's OIDC provider, with permissions scoped to Terraform actions.
For detailed OIDC setup instructions, see the `.github/workflows/CI-CD.yml` file and [GitHub’s guide on OIDC with AWS](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect).
