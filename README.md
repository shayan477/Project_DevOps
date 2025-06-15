🚀 One-Click Jenkins Pipeline Deployment
A fully automated DevOps pipeline using Jenkins (Dockerized) that provisions infrastructure on Azure, configures it with Ansible, and deploys a static website — all from a single Jenkins pipeline.

🛠️ Technology Stack
| Tool          | Purpose                                     |
| ------------- | ------------------------------------------- |
| **Docker**    | Run Jenkins in a container                  |
| **Jenkins**   | Automate the entire pipeline process        |
| **Terraform** | Provision Azure virtual machine             |
| **Ansible**   | Configure VM and deploy static web content  |
| **Azure**     | Cloud provider for hosting the VM           |
| **Git**       | Version control for infrastructure and code |

📁 Project Structure
project1/
├── terraform/          # Terraform config to provision Azure VM
│   ├── main.tf
│   ├── variables.tf
│   ├── secrets.auto.tfvars     # (or use environment variables)
│   └── verify.tf               # Optional: Terraform config check
├── ansible/            # Ansible playbook & dynamic inventory
│   └── install_web.yml
├── app/                # Static website content
│   └── index.html
├── Jenkinsfile         # CI/CD pipeline definition
└── README.md           # Project documentation

⚙️ Prerequisites
Azure service principal (populate secrets.auto.tfvars or export the following):
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_CLIENT_ID="your-sp-client-id"
export ARM_CLIENT_SECRET="your-sp-client-secret"
export ARM_TENANT_ID="your-tenant-id"

SSH Key Pair:

Public key (~/.ssh/id_rsa.pub) is injected into the VM

Private key must be added to Jenkins credentials for Ansible SSH

Docker & Jenkins installed

Jenkins container should have access to:

terraform

ansible-playbook

Your local project directory

🐳 Running Jenkins in Docker
docker run -d \
  --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(which terraform):/usr/local/bin/terraform \
  -v $(which ansible-playbook):/usr/local/bin/ansible-playbook \
  -v $(pwd):/workspace \
  jenkins/jenkins:lts

🔌 Jenkins Setup Steps
After container is running:

Unlock Jenkins (initial password is in /var/jenkins_home/secrets/initialAdminPassword)

Install plugins:

Git

Pipeline

SSH Agent

Add SSH private key under Jenkins → Manage Credentials

🚀 Jenkins Pipeline Stages
Defined in the Jenkinsfile, executed sequentially:

Terraform Init & Apply – Provisions Ubuntu VM on Azure

Ansible Install – Installs Apache on the VM

Deploy App – Copies static site to /var/www/html/

Verify – Runs curl to check successful deployment


✅ Output
After successful execution, access your deployed static website at:
http://<Azure-VM-Public-IP>:80

