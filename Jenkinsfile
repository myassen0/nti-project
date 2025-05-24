pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    withCredentials([
                        string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        sh 'terraform init'
                        sh 'terraform import aws_key_pair.deployer deployer-key || true'
                        sh 'terraform apply -auto-approve > tf_output.txt'
                    }
                }
            }
        }

        stage('Extract EC2 IP') {
            steps {
                dir('terraform') {
                    script {
                        def ip = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()
                        writeFile file: '../ansible/ec2_ip.txt', text: ip
                    }
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('ansible') {
                    withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                        script {
                            def ip = readFile('ec2_ip.txt').trim()
                            writeFile file: 'dynamic_inventory.ini', text: "${ip} ansible_user=ec2-user ansible_ssh_private_key_file=${SSH_KEY}"
                            sh 'ansible-playbook -i dynamic_inventory.ini playbook.yml --ssh-common-args="-o StrictHostKeyChecking=no"'
                        }
                    }
                }
            }
        }
    }
}
