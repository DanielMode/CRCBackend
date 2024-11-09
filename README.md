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
- Terraform
- GitHub account with repository access

## Installation and Setup
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/DanielMode/CRCBackend.git
   cd CRCBackend
