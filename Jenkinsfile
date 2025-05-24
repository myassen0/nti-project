pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials', // Replace with your AWS credentials ID
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh 'terraform init'
                        sh 'terraform apply -auto-approve'
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
                            sh """#!/bin/bash
echo "${ip} ansible_user=ec2-user ansible_ssh_private_key_file=${SSH_KEY}" > dynamic_inventory.ini
ansible-playbook -i dynamic_inventory.ini playbook.yml --ssh-common-args="-o StrictHostKeyChecking=no"
"""
                        }
                    }
                }
            }
        }
    }
}
