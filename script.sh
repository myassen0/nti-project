#!/bin/bash

set -e
set -u

LOG_FILE="/var/log/jenkins-init.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "========== Starting EC2 initialization =========="

echo "[+] Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "[+] Installing core packages..."
sudo apt-get install -y nginx git curl unzip ufw

echo "[+] Configuring UFW firewall rules..."
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

echo "[+] Starting and enabling NGINX..."
sudo systemctl enable nginx
sudo systemctl start nginx

echo "[+] Setting up branded index.html..."
sudo bash -c 'cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
  <title>NTI EC2 Deployment</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f9f9f9;
      color: #333;
      text-align: center;
      padding: 50px;
    }
    h1 {
      color: #007acc;
      margin-bottom: 10px;
    }
    h3 {
      color: #555;
    }
    img {
      max-width: 200px;
      margin-bottom: 30px;
    }
    .footer {
      margin-top: 40px;
      font-size: 14px;
      color: #888;
    }
  </style>
</head>
<body>
  <img src="https://www.nti.sci.eg/images/logo.png" alt="NTI Logo">
  <h1>🚀 EC2 Deployed via Jenkins Pipeline</h1>
  <h3>By: Mahmoud Yassen</h3>
  <h3>Supervised by: Eng. Mohamed Swelam</h3>
  <p>This server was provisioned with Terraform and configured using Ansible.</p>
  <div class="footer">National Telecommunication Institute - NTI</div>
</body>
</html>
EOF'

echo "========== EC2 initialization complete =========="
