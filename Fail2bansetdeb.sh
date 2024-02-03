#!/bin/bash

echo "This script will install and configure Fail2Ban on your Debian system."
echo "Please ensure you are running this script with sufficient privileges."
read -p "Press Enter to update your system's package list or CTRL+C to abort..."

# Update system's package list
sudo apt-get update

echo "System package list updated."
read -p "Press Enter to install Fail2Ban or CTRL+C to abort..."

# Install Fail2Ban
sudo apt-get install -y fail2ban

echo "Fail2Ban installed."
read -p "Press Enter to configure Fail2Ban for SSH monitoring or CTRL+C to abort..."

# Configure Fail2Ban
sudo tee /etc/fail2ban/jail.local <<EOF
[DEFAULT]
ignoreip = 127.0.0.1/8
bantime  = 3600
findtime  = 600
maxretry = 3

[sshd]
enabled = true
port    = ssh
filter  = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF

echo "Fail2Ban configured for SSH monitoring."
read -p "Press Enter to restart and enable Fail2Ban service or CTRL+C to abort..."

# Restart and Enable Fail2Ban
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban

echo "Fail2Ban service restarted and enabled to start on boot."
echo "Installation and configuration complete."

