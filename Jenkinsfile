pipeline {
agent any

environment {
TF_DIR = 'terraform'
ANSIBLE_DIR = 'ansible'
}

stages {
stage('Prepare Workspace') {
steps {
deleteDir()
sh '''
echo "Copying Terraform configs..."
cp -r /workspace/${TF_DIR}/* .
'''
sh 'ls -R'
}
}stage('Setup Azure Credentials & Terraform') {
  steps {
    withCredentials([
      string(credentialsId: 'AZ_SUB_ID_CRED', variable: 'ARM_SUBSCRIPTION_ID'),
      string(credentialsId: 'AZ_CLIENT_ID_CRED', variable: 'ARM_CLIENT_ID'),
      string(credentialsId: 'AZ_CLIENT_SECRET_CRED', variable: 'ARM_CLIENT_SECRET'),
      string(credentialsId: 'AZ_TENANT_ID_CRED', variable: 'ARM_TENANT_ID')
    ]) {
      sh '''
        echo "Exporting ARM_* variables..."
        export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
        export ARM_CLIENT_ID=$ARM_CLIENT_ID
        export ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET
        export ARM_TENANT_ID=$ARM_TENANT_ID

        echo "Running Terraform..."
        cd .
        terraform init
        terraform apply -auto-approve
      '''
    }
  }
}

stage('Ansible Deploy') {
  steps {
    sshagent(['azure_ssh']) {
      sh '''
        echo "Running Ansible playbook..."
        cd /workspace/${ANSIBLE_DIR}
        ansible-playbook -i inventory install_web.yml --private-key ~/.ssh/id_rsa
      '''
    }
  }
}

stage('Verify Web') {
  steps {
    sh '''
      echo "Verifying webpage via curl..."
      PUBLIC_IP=$(terraform output -raw public_ip1)
      echo "Public IP: $PUBLIC_IP"
      curl --retry 5 --retry-delay 10 http://$PUBLIC_IP
    '''
  }
}
}

post {
always {
echo 'Pipeline finished.'
}
}
}
