#Description:
#This script performs multiple administrative tasks relating to SSH configuration, user management and command history.
#It backs up SSH configuration, disables root login if enabled, lists currently logged in users, and prompts for password changes and well as to clear command history.

 
#!/bin/bash

# Backup SSH configuration
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Step 1: Check if root login is enabled
root_login_enabled=$(awk '/^PermitRootLogin[ \t]+yes$/{print $0}' /etc/ssh/sshd_config | wc -l)

if [ "$root_login_enabled" -eq 1 ]; then
    # Step 2: Disable root login
    echo "Disabling root login..."
    sudo sed -i '/^PermitRootLogin[ \t]+yes$/s/yes/no/' /etc/ssh/sshd_config
    sudo systemctl reload sshd
    echo "Root login disabled."
else
    echo "Root login is already disabled."
fi

# Step 3: List current logged-in users
echo "Currently logged-in users:"
who

# Step 4: Prompt for password changes
read -p "Do you want to prompt users to change their passwords? (y/n): " prompt_change_passwords

if [ "$prompt_change_passwords" = "y" ]; then
    for user in $(getent passwd | awk -F: '$3>=1000{print $1}'); do
        echo "Consider changing password for: $user"
    done
    read -p "Proceed with password changes? (y/n): " confirm_changes
    if [ "$confirm_changes" = "y" ]; then
        for user in $(getent passwd | awk -F: '$3>=1000{print $1}'); do
            read -p "Change password for $user? (y/n): " change_password
            if [ "$change_password" = "y" ]; then
                sudo passwd $user
            fi
        done
        echo "Password changes completed."
    else
        echo "Password changes aborted."
    fi
else
    echo "Password changes not performed."
fi

# Step 5: Clear command history
read -p "Do you want to clear the command history for the current user? (y/n): " clear_history

if [ "$clear_history" = "y" ]; then
    echo "Clearing command history..."
    history -c && history -w
    echo "Command history cleared."
else
    echo "Command history not cleared."
fi
