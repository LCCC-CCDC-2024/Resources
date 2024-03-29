#Description:
#This script is designed to create a bootable USB drive from an ISO file. 

#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# List available disk drives
echo "Available drives:"
lsblk -d -o NAME,SIZE,MODEL
echo ""

# Prompt user to select the target USB drive
read -p "Enter the device name of your USB drive (e.g., sdb): " usb_drive
usb_drive="/dev/${usb_drive}"

# Validate the selected USB drive
if [ ! -e "$usb_drive" ]; then
  echo "The device $usb_drive does not exist. Please check the device name and try again."
  exit 1
fi

# Warn the user about data loss
echo "WARNING: All data on $usb_drive will be destroyed!"
read -p "Are you sure you want to continue? (type YES to confirm): " confirmation

if [ "$confirmation" != "YES" ]; then
  echo "Operation cancelled by the user."
  exit 0
fi

# Prompt user to specify the ISO file path
read -p "Enter the full path to the ISO file: " iso_path

# Validate the ISO file path
if [ ! -f "$iso_path" ]; then
  echo "The file $iso_path does not exist. Please check the file path and try again."
  exit 1
fi

# Final confirmation before proceeding
echo "You are about to write $iso_path to $usb_drive."
read -p "Are you sure you want to proceed? (type YES to confirm): " final_confirmation

if [ "$final_confirmation" != "YES" ]; then
  echo "Operation cancelled by the user."
  exit 0
fi

# Execute the dd command
echo "Writing ISO to USB drive. Please wait..."
dd if="$iso_path" of="$usb_drive" bs=4M status=progress oflag=sync

echo "Bootable USB drive created successfully."

