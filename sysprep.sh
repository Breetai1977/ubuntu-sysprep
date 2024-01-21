#!/bin/bash

# sysprep Ubuntu for cloning

this_file=${0##*/}
this_user=$SUDO_USER

id

if [`id -u` -ne 0]; then
  echo Need to run with sudo
  exit 1
fi

cd ~

wget https://raw.githubusercontent.com/Breetai1977/ubuntu-sysprep/main/run_first.sh
chmod +rwx run_first.sh
chown $this_user:$this_user run_first.sh

# update apt cache
apt update

# install packages
apt install -y qemu-guest-agent chrony

# flush the logs
logrotate -f /etc/logrotate.conf

# stop services
service rsyslog stop

# clear logs
if [ -f /var/log/audit/audit.log ]; then
  cat /dev/null > /var/log/audit/audit.log
fi
if [ -f /var/log/wtmp ]; then
  cat /dev/null > /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
  cat /dev/null > /var/log/lastlog
fi

# claenup persistent udev rules
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
  rm /etc/udev/rules.d/70-persistent-net.rules
fi

# cleanup tmp directories
rm -rf /tmp/*
rm -rf /var/tmp/*

# cleanup current ssh keys
rm -f /etc/ssh/ssh_host_*

# cleanup apt
apt clean
apt autoremove

# cleanup machine-id
if [ -f /etc/machine-id ]; then
  cat /dev/null > /etc/machine-id
fi
if [ - /var/lib/dbus/machine-id ]; then
  cat /dev/null > /var/lib/dbus/machine-id
fi

rm ~/$this_file

echo "\nShutdown and setup this VM template for cloning.\"
