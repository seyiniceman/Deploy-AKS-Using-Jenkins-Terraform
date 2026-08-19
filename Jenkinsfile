pipeline {
    agent any

    environment {
        AZURE_RESOURCE_GROUP = "DevLab"
        AKS_CLUSTER_NAME     = "myapp-aks-cluster"
        AZURE_LOCATION       = "swedencentral"
    }

    stages {

        stage('Check Tools') {
            steps {
                sh '''
                    echo "=== Checking installed tools ==="

                    terraform version
                    az version
                    kubectl version --client
                '''
            }
        }

        stage('Azure Login') {
            steps {
                withCredentials([
                    string(credentialsId: 'azure-client-id', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'azure-client-secret', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'azure-tenant-id', variable: 'ARM_TENANT_ID'),
                    string(credentialsId: 'azure-subscription-id', variable: 'ARM_SUBSCRIPTION_ID')
                ]) {

                    sh '''
                        echo "=== Authenticating Jenkins with Azure ==="

                        az login \
                          --service-principal \
                          --username "$ARM_CLIENT_ID" \
                          --password "$ARM_CLIENT_SECRET" \
                          --tenant "$ARM_TENANT_ID"

                        az account set \
                          --subscription "$ARM_SUBSCRIPTION_ID"

                        az account show
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    string(credentialsId: 'azure-client-id', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'azure-client-secret', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'azure-tenant-id', variable: 'ARM_TENANT_ID'),
                    string(credentialsId: 'azure-subscription-id', variable: 'ARM_SUBSCRIPTION_ID')
                ]) {

                    sh '''
                        echo "=== Terraform Init ==="

                        terraform init -input=false
                    '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                sh '''
                    echo "=== Terraform Validate ==="

                    terraform validate
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'azure-client-id', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'azure-client-secret', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'azure-tenant-id', variable: 'ARM_TENANT_ID'),
                    string(credentialsId: 'azure-subscription-id', variable: 'ARM_SUBSCRIPTION_ID')
                ]) {

                    sh '''
                        echo "=== Terraform Plan ==="

                        terraform plan \
                          -input=false \
                          -out=tfplan
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    string(credentialsId: 'azure-client-id', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'azure-client-secret', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'azure-tenant-id', variable: 'ARM_TENANT_ID'),
                    string(credentialsId: 'azure-subscription-id', variable: 'ARM_SUBSCRIPTION_ID')
                ]) {

                    sh '''
                        echo "=== Creating Azure Infrastructure ==="

                        terraform apply \
                          -input=false \
                          -auto-approve \
                          tfplan
                    '''
                }
            }
        }

        stage('Configure AKS Access') {
            steps {
                withCredentials([
                    string(credentialsId: 'azure-client-id', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'azure-client-secret', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'azure-tenant-id', variable: 'ARM_TENANT_ID'),
                    string(credentialsId: 'azure-subscription-id', variable: 'ARM_SUBSCRIPTION_ID')
                ]) {

                    sh '''
                        echo "=== Connecting Jenkins to AKS ==="

                        az login \
                          --service-principal \
                          --username "$ARM_CLIENT_ID" \
                          --password "$ARM_CLIENT_SECRET" \
                          --tenant "$ARM_TENANT_ID"

                        az account set \
                          --subscription "$ARM_SUBSCRIPTION_ID"

                        mkdir -p ~/.kube

                        az aks get-credentials \
                          --resource-group "$AZURE_RESOURCE_GROUP" \
                          --name "$AKS_CLUSTER_NAME" \
                          --overwrite-existing
                    '''
                }
            }
        }

        stage('Verify AKS Cluster') {
            steps {
                sh '''
                    echo "=== Verifying AKS Cluster ==="

                    kubectl get nodes

                    kubectl get namespaces

                    kubectl get pods -A
                '''
            }
        }
    }

    post {
        success {
            echo 'Azure AKS pipeline completed successfully.'
        }

        failure {
            echo 'Azure AKS pipeline failed. Check the Jenkins console output.'
        }

        always {
            echo 'Pipeline completed.'

            sh '''
                az logout || true
            '''
        }
    }
}

