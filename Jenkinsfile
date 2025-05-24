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
                script {
                    def output = readFile('terraform/tf_output.txt')
                    def ec2_ip = output.find(/(\d+\.\d+\.\d+\.\d+)/)
                    writeFile file: 'ansible/ec2_ip.txt', text: ec2_ip
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('ansible') {
                    withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                        script {
                            def ip = readFile('ec2_ip.txt').trim()
                            sh '''#!/bin/bash
                            echo "$ip ansible_user=ec2-user ansible_ssh_private_key_file=$SSH_KEY" > dynamic_inventory.ini
                            ansible-playbook -i dynamic_inventory.ini playbook.yml --ssh-common-args="-o StrictHostKeyChecking=no"
                            '''
                        }
                    }
                }
            }
        }
    }
}
