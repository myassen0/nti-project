pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform init'

                    // محاول استيراد المفتاح إذا كان موجود مسبقاً
                    sh 'terraform import aws_key_pair.deployer deployer-key || true'

                    // تطبيق التكوين
                    sh 'terraform apply -auto-approve > tf_output.txt'
                }
            }
        }

        stage('Extract EC2 IP') {
            steps {
                script {
                    def output = readFile('terraform/tf_output.txt')
                    def ec2_ip = output.find(/(\d+\.\d+\.\d+\.\d+)/)
                    writeFile file: 'ansible/inventory.ini', text: "${ec2_ip} ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/deployer-key"
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('ansible') {
                    sh 'ansible-playbook -i inventory.ini playbook.yml'
                }
            }
        }
    }
}
