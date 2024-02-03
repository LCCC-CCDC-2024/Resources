#!/bin/bash

# Install EPEL Repository
sudo yum install -y epel-release

# Update system's package list
sudo yum update -y

# Install Fail2Ban
sudo yum install -y fail2ban

# Configure Fail2Ban
sudo tee /etc/fail2ban/jail.local <<EOF
[DEFAULT]
ignoreip = 127.0.0.1/8
bantime  = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port    = ssh
filter  = sshd
logpath = /var/log/secure
maxretry = 3
EOF

# Enable and Start Fail2Ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

