 #!/bin/bash

# Function to install and configure Fail2ban
install_fail2ban() {
    echo "Installing Fail2ban..."
    pacman -Syu fail2ban
    systemctl enable fail2ban
    systemctl start fail2ban
    echo "Fail2ban installed and configured."
}

# Function to install and run Lynis for security auditing
run_lynis_audit() {
    echo "Installing Lynis..."
    pacman -Syu lynis
    echo "Running Lynis audit..."
    lynis audit system
}

# Function to install and use Nmap for network scanning
install_nmap() {
    echo "Installing Nmap..."
    pacman -Syu nmap
    echo "Nmap installed. Use 'nmap' command to scan your network."
}

# Function to configure firewalld for KDE Connect
configure_kde_connect() {
    echo "Configuring firewall for KDE Connect..."
    firewall-cmd --zone=public --add-port=1714-1764/tcp --permanent
    firewall-cmd --zone=public --add-port=1714-1764/udp --permanent
    firewall-cmd --reload
    echo "KDE Connect configured successfully."
}

# Main menu system
while true; do
    echo "Select an option:"
    echo "1) Install and configure Fail2ban"
    echo "2) Run Lynis security audit"
    echo "3) Install Nmap"
    echo "4) Configure firewall for KDE Connect"
    echo "5) Exit"
    read -p "Enter choice: " choice
    case "$choice" in
        1) install_fail2ban ;;
        2) run_lynis_audit ;;
        3) install_nmap ;;
        4) configure_kde_connect ;;
        5) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid choice, please try again." ;;
    esac
done

