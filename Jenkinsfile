pipeline {
  agent any

  environment {
    TF_DIR      = 'terraform'
    ANSIBLE_DIR = 'ansible'
  }

  stages {
    stage('Checkout') {
      steps {
        // code is already checked out by SCM
        echo 'Workspace contains:' 
        sh 'ls -R \$WORKSPACE'
      }
    }

    stage('Terraform Apply') {
      steps {
        withCredentials([
          string(credentialsId: 'AZ_SUB_ID_CRED',        variable: 'ARM_SUBSCRIPTION_ID'),
          string(credentialsId: 'AZ_CLIENT_ID_CRED',     variable: 'ARM_CLIENT_ID'),
          string(credentialsId: 'AZ_CLIENT_SECRET_CRED', variable: 'ARM_CLIENT_SECRET'),
          string(credentialsId: 'AZ_TENANT_ID_CRED',     variable: 'ARM_TENANT_ID'),
        ]) {
          sh '''
            echo "Exporting ARM_* variables..."
            export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
            export ARM_CLIENT_ID=$ARM_CLIENT_ID
            export ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET
            export ARM_TENANT_ID=$ARM_TENANT_ID

            echo "Running Terraform..."
            cd \$WORKSPACE/${TF_DIR}
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
            cd \$WORKSPACE/${ANSIBLE_DIR}
            ansible-playbook -i inventory install_web.yml --private-key ~/.ssh/id_rsa
          '''
        }
      }
    }

    stage('Verify Web') {
      steps {
        script {
          def ip = sh(
            script: "terraform -chdir=\$WORKSPACE/${TF_DIR} output -raw public_ip1",
            returnStdout: true
          ).trim()
          echo "Verifying page at http://\$ip"
          sh "curl --retry 5 --retry-delay 10 http://\$ip"
        }
      }
    }
  }

  post {
    always {
      echo 'Pipeline finished.'
    }
  }
}
