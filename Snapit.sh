#Description:
#This script is designed to capture all active and ended services in a snapshot. It also has rollback services and Timeshift, used for Linux computers.


#!/bin/bash

# Global variables
SNAPSHOT_FILE="/tmp/running_services_snapshot.txt"
STOPPED_SERVICES_FILE="/tmp/stopped_services_snapshot.txt"

# Pause function for user interaction
function pause() {
    read -p "Press [Enter] key to continue..."
}

# Enhanced visual menu display function
function show_menu() {
    clear  # Clear the screen for readability
    echo "=================== Service Snapshot Manager ==================="
    echo "|                                                               |"
    echo "| 1) Take a snapshot of services                                |"
    echo "| 2) Compare current services with snapshot                     |"
    echo "| 3) Roll back to snapshot state                                |"
    echo "| 4) Install Timeshift on Debian-based systems                  |"
    echo "| 5) Install Timeshift on CentOS                                |"
    echo "| 6) Install Timeshift on Arch Linux                            |"
    echo "| 7) Exit                                                       |"
    echo "|                                                               |"
    echo "================================================================"
    echo ""
}

# Function to take a snapshot of currently running and stopped services
function take_snapshot() {
    systemctl list-units --type=service --state=running | grep ".service" | awk '{print $1}' | sort > "$SNAPSHOT_FILE"
    systemctl list-units --type=service --state=exited,failed | grep ".service" | awk '{print $1}' | sort > "$STOPPED_SERVICES_FILE"
    echo "Snapshot of active and stopped services taken."
    pause
}

# Function to roll back services to their state in the snapshot
function rollback_services() {
    echo "Rolling back services to snapshot state..."
    local current_services=$(mktemp)

    systemctl list-units --type=service --state=running | grep ".service" | awk '{print $1}' | sort > "$current_services"

    while IFS= read -r service; do
        if [[ $service == *.service ]]; then
            if ! systemctl is-active --quiet "$service"; then
                echo "Starting $service..."
                systemctl start "$service"
                if systemctl is-active --quiet "$service"; then
                    echo "$service started successfully."
                else
                    echo "Failed to start $service."
                fi
            fi
        fi
    done < "$SNAPSHOT_FILE"

    while IFS= read -r service; do
        if [[ $service == *.service ]]; then
            if systemctl is-active --quiet "$service" && ! grep -q "^${service}$" "$SNAPSHOT_FILE"; then
                echo "Stopping $service..."
                systemctl stop "$service"
                if ! systemctl is-active --quiet "$service"; then
                    echo "$service stopped successfully."
                else
                    echo "Failed to stop $service."
                fi
            fi
        fi
    done < "$current_services"

    rm "$current_services"
    echo "Services rolled back to snapshot state."
    pause
}

# Function to compare current services with the snapshot and prompt for actions
function compare_and_prompt() {
    echo "Comparing current services with the snapshot..."

    local current_running=$(mktemp)
    systemctl list-units --type=service --state=running | grep ".service" | awk '{print $1}' | sort > "$current_running"

    local current_stopped=$(mktemp)
    systemctl list-units --type=service --state=exited,failed | grep ".service" | awk '{print $1}' | sort > "$current_stopped"

    local stopped_services=$(comm -23 "$SNAPSHOT_FILE" "$current_running")
    local started_services=$(comm -23 "$current_stopped" "$STOPPED_SERVICES_FILE")

    if [ -z "$stopped_services" ] && [ -z "$started_services" ]; then
        echo "No changes detected in running services since the last snapshot."
    else
        if [ ! -z "$stopped_services" ]; then
            echo "The following services were running at the time of the snapshot but are not running now:"
            echo "$stopped_services"
            read -p "Do you want to attempt to restart these services? (y/n): " answer
            if [[ $answer =~ ^[Yy]$ ]]; then
                echo "$stopped_services" | while read service; do
                    echo "Attempting to restart $service..."
                    systemctl start "$service"
                done
            fi
        fi

        if [ ! -z "$started_services" ]; then
            echo "The following services were not running at the time of the snapshot but are running now:"
            echo "$started_services"
            read -p "Do you want to attempt to stop these services? (y/n): " answer
            if [[ $answer =~ ^[Yy]$ ]]; then
                echo "$started_services" | while read service; do
                    echo "Attempting to stop $service..."
                    systemctl stop "$service"
                done
            fi
        fi
    fi

    rm "$current_running" "$current_stopped"
    pause
}

# Functions to install Timeshift on various Linux distributions
function install_timeshift_deb() {
    sudo apt update
    sudo apt install timeshift -y
    echo "Timeshift installation completed on Debian-based system."
    pause
}

function install_timeshift_centos() {
    sudo yum install epel-release -y
    sudo yum update
    sudo yum install timeshift -y
    echo "Timeshift installation completed on CentOS."
    pause
}

function install_timeshift_arch() {
    sudo pacman -Sy timeshift --noconfirm
    echo "Timeshift installation completed on Arch Linux."
    pause
}

# Main function to handle user inputs and call corresponding functions
function main() {
    while true; do
        show_menu
        read -p "Enter your choice (1-7): " choice
        case "$choice" in
            1) take_snapshot ;;
            2) compare_and_prompt ;;
            3) rollback_services ;;
            4) install_timeshift_deb ;;
            5) install_timeshift_centos ;;
            6) install_timeshift_arch ;;
            7) echo "Exiting..." ; exit 0 ;;
            *) echo "Invalid option. Please try again." ;;
        esac
    done
}

# Call the main function to start the script
main
