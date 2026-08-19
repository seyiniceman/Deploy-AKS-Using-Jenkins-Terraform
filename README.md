Deploy Azure AKS Using Jenkins and Terraform
Provision an Azure Kubernetes Service (AKS) cluster using Terraform and automate the deployment through a Jenkins CI/CD pipeline while following Infrastructure as Code (IaC) best practices.
Project Overview
This project demonstrates how to provision a highly available Azure Kubernetes Service (AKS) cluster using Terraform while automating the entire Infrastructure as Code deployment process through a Jenkins CI/CD pipeline.
The infrastructure is created entirely from code, including the Azure Resource Group, Virtual Network, subnets, network security controls, and AKS cluster. Jenkins automates the Terraform workflow, ensuring every deployment follows a consistent, repeatable, and version-controlled process.
This project showcases real-world DevOps practices such as Infrastructure as Code, continuous integration, automation, Azure cloud provisioning, and Kubernetes orchestration.
Architecture Diagram
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
Objectives
- Automate Azure infrastructure provisioning
- Apply Infrastructure as Code best practices
- Provision a highly available AKS cluster
- Demonstrate a complete DevOps workflow
- Maintain consistent and version-controlled deployments
Technologies Used
- Microsoft Azure
- Azure Kubernetes Service (AKS)
- Terraform
- Jenkins
- GitHub
- Kubernetes
- Azure CLI
Repository Structure
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
Workflow
1. A developer pushes Terraform code changes to GitHub.
2. GitHub sends a webhook notification to Jenkins.
3. Jenkins checks out the latest repository version.
4. Jenkins runs terraform init.
5. Jenkins validates the Terraform configuration.
6. Jenkins generates and reviews the Terraform execution plan.
7. Jenkins applies the approved infrastructure changes.
8. Terraform creates the Azure networking resources and AKS cluster.
9. Jenkins configures kubectl using the AKS credentials.
10. Jenkins verifies that the Kubernetes nodes are ready.
Prerequisites
- Azure subscription
- Azure service principal or workload identity with the required permissions
- Azure CLI
- Terraform
- Jenkins
- kubectl
- Git
- GitHub repository
- Jenkins credentials configured securely for Azure authentication
Azure Authentication
Create an Azure service principal for Jenkins:
az ad sp create-for-rbac \
  --name "jenkins-terraform-aks" \
  --role "Contributor" \
  --scopes "/subscriptions/<subscription-id>"
Store the following values securely in Jenkins Credentials:
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
Do not commit these credentials to GitHub or place them directly in terraform.tfvars.
Deployment Steps
1. Clone the repository:
git clone <repo-url>
cd <repository-name>
2. Authenticate with Azure:
az login
az account set --subscription "<subscription-id>"
3. Initialize Terraform:
terraform init
4. Format and validate the configuration:
terraform fmt -check
terraform validate
5. Generate a Terraform execution plan:
terraform plan -out=tfplan
6. Apply the plan:
terraform apply tfplan
7. Configure kubectl:
az aks get-credentials \
  --resource-group <resource-group-name> \
  --name <cluster-name> \
  --overwrite-existing
8. Verify the Kubernetes nodes:
kubectl get nodes
9. Verify the cluster:
kubectl cluster-info
kubectl get namespaces
Jenkins Pipeline Stages
The Jenkins pipeline performs the following stages:
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
A manual approval stage before terraform apply is recommended for production environments.
Security Best Practices
- Store Azure credentials in Jenkins Credentials.
- Never commit client secrets or Terraform state files.
- Use an Azure Storage Account backend for remote Terraform state.
- Enable state locking through the Azure Blob Storage backend lease mechanism.
- Follow least-privilege access principles.
- Use managed identities for AKS workloads where possible.
- Enable Azure role-based access control for AKS.
- Restrict AKS API server access where appropriate.
- Use private AKS clusters for sensitive production workloads.
- Review the Terraform plan before applying infrastructure changes.
Skills Demonstrated
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
Project Outcome
Successfully automated the provisioning of an Azure Kubernetes Service cluster using Terraform through a Jenkins CI/CD pipeline. The solution provisions Azure networking resources, deploys a production-ready Kubernetes control plane and node pool, and provides a repeatable, version-controlled infrastructure deployment using Infrastructure as Code principles.
Author
Seyi Akinmusere
DevOps | Cloud Engineer | Azure | AWS | Terraform | Jenkins | Docker | Kubernetes
