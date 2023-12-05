#!/bin/bash
# Author:       Christo Deale                  
# Date  :       2023-12-27            
# sshfs_remote: Utility to interactively mount remote file systems over SSH using sshfs

# Check if sshfs and openssh are installed, and if not, install them
if ! command -v sshfs &> /dev/null || ! command -v ssh &> /dev/null; then
    sudo dnf install -y sshfs openssh
fi

# Prompt user for input
read -p "Enter username: " username
read -p "Enter host/IP: " host
read -p "Enter remote directory: " remote_directory

# Create local mount point directory in /mnt
read -p "Enter local mountpoint directory name: " mountpoint
local_mountpoint="/mnt/$mountpoint"
sudo mkdir -p "$local_mountpoint"

# Mount the remote directory using sshfs
sshfs "$username@$host:$remote_directory" "$local_mountpoint"

# Check if the mount was successful
if [ $? -eq 0 ]; then
    echo -e "\e[31msshfs mapped in RED\e[0m"

    # Add an entry to /etc/fstab
    echo "$username@$host:$remote_directory  $local_mountpoint  fuse.sshfs  defaults  0  0" | sudo tee -a /etc/fstab > /dev/null

    # Mount all entries in /etc/fstab
    sudo mount -a

    echo "Mount successful."
else
    echo "Mount failed."
fi
