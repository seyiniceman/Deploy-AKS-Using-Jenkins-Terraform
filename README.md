# Deploy Azure AKS Using Jenkins and Terraform

Provision an Azure Kubernetes Service (AKS) cluster using Terraform and automate the deployment through a Jenkins CI/CD pipeline while following Infrastructure as Code (IaC) best practices.

## Project Overview

This project demonstrates how to provision a highly available Azure Kubernetes Service (AKS) cluster using Terraform while automating the entire Infrastructure as Code (IaC) deployment process through a Jenkins CI/CD pipeline.

The infrastructure is created entirely from code, including the Azure Resource Group, Virtual Network, subnets, network security controls, and AKS cluster. Jenkins automates the Terraform workflow, ensuring every deployment follows a consistent, repeatable, and version-controlled process.

This project showcases real-world DevOps practices such as Infrastructure as Code, continuous integration, automation, Azure cloud provisioning, and Kubernetes orchestration.

## Architecture Diagram

```text
+----------------------+
|      Developer       |
+----------+-----------+
           |
           | Git Push
           v
+----------------------+
|       GitHub         |
+----------+-----------+
           |
           | Webhook
           v
+----------------------+
|      Jenkins CI      |
+----------+-----------+
           |
    +------+------+
    |             |
    v             v
terraform init   terraform validate
         \         /
          \       /
           v     v
      terraform plan
            |
            v
      terraform apply
            |
            v
+--------------------------------+
|             Azure              |
|--------------------------------|
| Resource Group                 |
| Virtual Network                |
| AKS Subnet                     |
| Network Security Group         |
| Azure Kubernetes Service       |
| AKS Node Pool                  |
+--------------------------------+
            |
            v
az aks get-credentials
            |
            v
kubectl get nodes
            |
            v
Kubernetes Cluster Ready
```

## Objectives

- Automate Azure infrastructure provisioning
- Apply Infrastructure as Code best practices
- Provision a highly available AKS cluster
- Demonstrate a complete DevOps workflow
- Maintain consistent and version-controlled deployments

## Technologies Used

- Microsoft Azure
- Azure Kubernetes Service (AKS)
- Terraform
- Jenkins
- GitHub
- Kubernetes
- Azure CLI

## Repository Structure

```text
.
├── Jenkinsfile
├── aks-cluster.tf
├── network.tf
├── resource-group.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars
├── versions.tf
├── .gitignore
└── README.md
```

## Workflow

1. A developer pushes Terraform code changes to GitHub.
2. GitHub sends a webhook notification to Jenkins.
3. Jenkins checks out the latest repository version.
4. Jenkins runs `terraform init`.
5. Jenkins validates the Terraform configuration.
6. Jenkins generates and reviews the Terraform execution plan.
7. Jenkins applies the approved infrastructure changes.
8. Terraform creates the Azure networking resources and AKS cluster.
9. Jenkins configures `kubectl` using the AKS credentials.
10. Jenkins verifies that the Kubernetes nodes are ready.

## Prerequisites

Before deploying the infrastructure, ensure you have the following:

- An active Azure subscription
- Azure CLI installed and configured
- Terraform installed
- Jenkins installed and configured
- `kubectl` installed
- Git installed
- A GitHub repository
- An Azure service principal or workload identity
- Jenkins credentials configured securely for Azure authentication
- Required permissions to create Azure resources

## Azure Authentication

Create an Azure service principal for Jenkins:

```bash
az ad sp create-for-rbac \
  --name "jenkins-terraform-aks" \
  --role "Contributor" \
  --scopes "/subscriptions/<subscription-id>"
```

Store the following values securely in Jenkins Credentials:

```text
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
```

Do not commit Azure credentials to GitHub or place them directly inside `terraform.tfvars`.

## Terraform Azure Provider Authentication

Terraform uses the following environment variables to authenticate with Azure:

```bash
export ARM_CLIENT_ID="<client-id>"
export ARM_CLIENT_SECRET="<client-secret>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"
```

In Jenkins, store these values as credentials and inject them into the pipeline securely.

## Deployment Steps

### 1. Clone the repository

```bash
git clone <repo-url>
cd <repository-name>
```

### 2. Authenticate with Azure

```bash
az login
az account set --subscription "<subscription-id>"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Format and validate the Terraform configuration

```bash
terraform fmt -check
terraform validate
```

### 5. Generate a Terraform execution plan

```bash
terraform plan -out=tfplan
```

### 6. Apply the Terraform plan

```bash
terraform apply tfplan
```

### 7. Configure kubectl

```bash
az aks get-credentials \
  --resource-group <resource-group-name> \
  --name <cluster-name> \
  --overwrite-existing
```

### 8. Verify the Kubernetes nodes

```bash
kubectl get nodes
```

### 9. Verify the Kubernetes cluster

```bash
kubectl cluster-info
kubectl get namespaces
```

## Jenkins Pipeline Stages

The Jenkins pipeline performs the following stages:

```text
Checkout
   |
   v
Terraform Format Check
   |
   v
Terraform Init
   |
   v
Terraform Validate
   |
   v
Terraform Plan
   |
   v
Manual Approval
   |
   v
Terraform Apply
   |
   v
Configure kubectl
   |
   v
Verify AKS Cluster
```

A manual approval stage before `terraform apply` is recommended for production environments.

## Example Jenkins Pipeline

```groovy
pipeline {
    agent any

    environment {
        ARM_CLIENT_ID       = credentials('azure-client-id')
        ARM_CLIENT_SECRET   = credentials('azure-client-secret')
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        ARM_TENANT_ID       = credentials('azure-tenant-id')

        RESOURCE_GROUP = 'aks-resource-group'
        AKS_CLUSTER    = 'aks-cluster'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Format Check') {
            steps {
                sh 'terraform fmt -check'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Approval') {
            steps {
                input message: 'Apply the Terraform plan to Azure?'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Configure kubectl') {
            steps {
                sh '''
                    az aks get-credentials \
                      --resource-group "$RESOURCE_GROUP" \
                      --name "$AKS_CLUSTER" \
                      --overwrite-existing
                '''
            }
        }

        stage('Verify AKS Cluster') {
            steps {
                sh 'kubectl get nodes'
                sh 'kubectl cluster-info'
            }
        }
    }
}
```

Update the Jenkins credential IDs, resource group name, and AKS cluster name to match your environment.

## GitHub Webhook Configuration

To trigger Jenkins automatically when code is pushed to GitHub:

1. Open the GitHub repository.
2. Select **Settings**.
3. Select **Webhooks**.
4. Select **Add webhook**.
5. Enter the Jenkins webhook URL:

```text
https://<jenkins-domain>/github-webhook/
```

6. Set the content type to:

```text
application/json
```

7. Select **Just the push event**.
8. Ensure the webhook is active.
9. Save the webhook.

In the Jenkins pipeline configuration, enable:

```text
GitHub hook trigger for GITScm polling
```

## Terraform State Management

For production environments, use an Azure Storage Account as the Terraform remote backend.

Example backend configuration:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstateaccount"
    container_name       = "tfstate"
    key                  = "aks/terraform.tfstate"
  }
}
```

The remote backend provides:

- Centralized Terraform state storage
- State locking through Azure Blob Storage leases
- Improved collaboration
- Better protection against local state loss
- Separation of infrastructure state from source code

## Security Best Practices

- Store Azure credentials in Jenkins Credentials.
- Never commit client secrets to GitHub.
- Never commit Terraform state files.
- Use an Azure Storage Account backend for remote Terraform state.
- Follow the principle of least privilege.
- Use managed identities for AKS workloads where possible.
- Enable Azure role-based access control for AKS.
- Restrict AKS API server access where appropriate.
- Use private AKS clusters for sensitive production workloads.
- Review the Terraform plan before applying changes.
- Rotate service principal secrets regularly.
- Protect Jenkins with HTTPS and authentication.
- Restrict access to the Jenkins pipeline.
- Store sensitive Terraform variables securely.

## Recommended `.gitignore`

```gitignore
# Terraform directories
**/.terraform/*

# Terraform state files
*.tfstate
*.tfstate.*

# Terraform crash logs
crash.log
crash.*.log

# Terraform variable files containing sensitive information
*.tfvars
*.tfvars.json

# Terraform plan files
*.tfplan
tfplan

# Terraform lock information
.terraform.tfstate.lock.info

# Local Terraform override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# CLI configuration files
.terraformrc
terraform.rc

# Environment files
.env
.env.*

# IDE files
.vscode/
.idea/

# Operating system files
.DS_Store
Thumbs.db
```

If your `terraform.tfvars` file does not contain sensitive information and you intentionally want to commit it, remove `*.tfvars` from `.gitignore`.

## Cleanup

To remove the infrastructure created by Terraform:

```bash
terraform plan -destroy
terraform destroy
```

Confirm the destruction when prompted.

For automated cleanup:

```bash
terraform destroy -auto-approve
```

Use the destroy command carefully because it permanently removes the provisioned Azure resources.

## Troubleshooting

### Verify Azure authentication

```bash
az account show
```

### List available Azure subscriptions

```bash
az account list --output table
```

### Select the correct Azure subscription

```bash
az account set --subscription "<subscription-id>"
```

### Verify AKS credentials

```bash
az aks get-credentials \
  --resource-group <resource-group-name> \
  --name <cluster-name> \
  --overwrite-existing
```

### Verify the current Kubernetes context

```bash
kubectl config current-context
```

### Display all Kubernetes contexts

```bash
kubectl config get-contexts
```

### Verify the AKS nodes

```bash
kubectl get nodes -o wide
```

### Reinitialize Terraform

```bash
terraform init -reconfigure
```

## Skills Demonstrated

- Infrastructure as Code with Terraform
- Azure Kubernetes Service
- Jenkins CI/CD
- Kubernetes
- Azure networking
- Azure identity and access management
- Git and GitHub
- Azure CLI
- Linux administration
- CI/CD automation
- Terraform state management
- Cloud security best practices

## Project Outcome

Successfully automated the provisioning of an Azure Kubernetes Service cluster using Terraform through a Jenkins CI/CD pipeline.

The solution provisions Azure networking resources, deploys a production-ready Kubernetes control plane and node pool, and provides a repeatable, consistent, and version-controlled infrastructure deployment using Infrastructure as Code principles.

The project demonstrates how Terraform, Jenkins, GitHub, Azure, and Kubernetes can be integrated to create an automated cloud infrastructure deployment workflow.

## Author

**Seyi Akinmusere**

DevOps | Cloud Engineer | Azure | AWS | Terraform | Jenkins | Docker | Kubernetes