pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }

    stages {
        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials'
                    ]]) {
                        sh 'terraform init'
                        sh 'terraform import aws_key_pair.deployer deployer-key'
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Extract EC2 IP') {
            steps {
                script {
                    def ip = readFile('terraform/ec2-ip.txt').trim()
                    writeFile file: 'ansible/inventory.ini', text: "${ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/deployer-key.pem"
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('ansible') {
                    sh 'ansible-playbook -i inventory.ini playbook.yml --ssh-common-args="-o StrictHostKeyChecking=no"'
                }
            }
        }
    }
}
