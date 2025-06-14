pipeline {
  agent any

  tools {
    terraform 'terraform'    // this must match the name you gave in Global Tool Config
  }

  environment {
    ANSIBLE_DIR = 'ansible'
    TF_DIR      = 'terraform'
  }

  stages {
    stage('Checkout') {
      steps {
        echo "Workspace contents:"
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
            echo "Exporting ARM_* vars..."
            export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
            export ARM_CLIENT_ID=$ARM_CLIENT_ID
            export ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET
            export ARM_TENANT_ID=$ARM_TENANT_ID

            echo "Running Terraform in \$WORKSPACE/${TF_DIR}"
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
          echo "Verifying http://$ip ..."
          sh "curl --retry 5 --retry-delay 5 http://$ip"
        }
      }
    }
  }

  post {
    always {
      echo 'Pipeline complete.'
    }
  }
}
