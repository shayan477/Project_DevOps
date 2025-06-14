pipeline {
    agent any
    
    environment {
        WORKSPACE_PATH = '/workspace'
    }
    
    stages {
        stage('Prepare Workspace') {
            steps {
                // Clean workspace
                deleteDir()
                
                // Copy the entire project structure
                sh '''
                    echo "Copying project structure..."
                    cp -r ${WORKSPACE_PATH}/project1/* .
                    
                    echo "Current directory structure:"
                    ls -la
                    
                    echo "Checking terraform directory:"
                    ls -la terraform/
                '''
            }
        }
        
        stage('Setup Azure Credentials & Terraform') {
            steps {
                withCredentials([
                    string(credentialsId: 'azure-subscription-id', variable: 'ARM_SUBSCRIPTION_ID'),
                    string(credentialsId: 'azure-client-id', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'azure-client-secret', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'azure-tenant-id', variable: 'ARM_TENANT_ID')
                ]) {
                    sh '''
                        echo "Exporting ARM_* variables..."
                        export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
                        export ARM_CLIENT_ID=$ARM_CLIENT_ID
                        export ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET
                        export ARM_TENANT_ID=$ARM_TENANT_ID
                        
                        echo "Running Terraform..."
                        cd terraform
                        
                        echo "Initializing Terraform..."
                        terraform init
                        
                        echo "Planning Terraform..."
                        terraform plan
                        
                        echo "Applying Terraform..."
                        terraform apply -auto-approve
                        
                        echo "Getting VM IP..."
                        VM_IP=$(terraform output -raw vm_public_ip)
                        echo "VM IP: $VM_IP"
                        
                        # Save VM IP for later stages
                        echo $VM_IP > ../vm_ip.txt
                    '''
                }
            }
        }
        
        stage('Wait for VM') {
            steps {
                sh '''
                    VM_IP=$(cat vm_ip.txt)
                    echo "Waiting for VM $VM_IP to be ready..."
                    
                    # Wait for SSH to be available
                    timeout 300 bash -c '
                        until nc -z $VM_IP 22; do
                            echo "Waiting for SSH on $VM_IP..."
                            sleep 10
                        done
                    '
                    echo "VM is ready!"
                '''
            }
        }
        
        stage('Ansible Deploy') {
            steps {
                sshagent(['ansible-ssh-key']) {
                    sh '''
                        VM_IP=$(cat vm_ip.txt)
                        echo "Deploying to VM: $VM_IP"
                        
                        # Create dynamic inventory
                        echo "[webservers]" > ansible/inventory
                        echo "$VM_IP ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ansible/inventory
                        
                        echo "Inventory content:"
                        cat ansible/inventory
                        
                        echo "Running Ansible playbook..."
                        cd ansible
                        ansible-playbook -i inventory install_web.yml -v
                    '''
                }
            }
        }
        
        stage('Verify Web') {
            steps {
                sh '''
                    VM_IP=$(cat vm_ip.txt)
                    echo "Verifying web server on $VM_IP..."
                    
                    # Test HTTP response
                    curl -f http://$VM_IP || (echo "Web server verification failed" && exit 1)
                    
                    echo "Web server is responding successfully!"
                '''
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline finished.'
        }
        failure {
            echo 'Pipeline failed!'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
    }
}
