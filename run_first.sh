#!/bin/sh

# Run after creating a clone

this_file=${0##*/}

id

if [ `id -u` -ne 0 ]; then
  echo Need to run with sudo
  exit 1
fi

# Chane the machine-id
dbus-uuidgen --ensure

# Change VM Name
echo -n "Set the name of this VM: "
read vm_name_input

new_vm_name=$(echo $vm_name_input | tr '[:upper:]' '[:lower:]' | tr -d [:space:])
current_vm_name=$(cat /etc/hostname)
hostnamectl set-hostname $new_vm_name
hostname $new_vm_name
sudo sed -i "s/$current_vm_name/$new_vm_name/g" /etc/hosts
sudo sed -i "s/$current_vm_name/$new_vm_name/g" /etc/hostname

# set timezone
timedatectl set-timezone America/Phoenix

# update apt-cache
apt update

# update OS
apt -y full-upgrade

#regenerate ssh host keys
test -f /etc/ssh/ssh_host_rsa_key || dpkg-reconfigure openssh-server

rm $this_file

echo "\nPlease reboot this VM now.\n"
