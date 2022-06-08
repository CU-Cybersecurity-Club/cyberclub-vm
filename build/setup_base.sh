#!/bin/bash
#
# Initializes a new Kali install so that it can be used as a base box for Vagrant. This script should be run within the Kali vm.

# Flags and helpers for better error handling
set -euo pipefail
trap 's=$?; echo >&2 "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
IFS=$'\n\t'

# SSH must be running
sudo systemctl enable ssh
sudo systemctl start ssh

# Setup the insecure vagrant public key so vagrant can interactively login
mkdir ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
# Insecure vagrant public key:
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key' >> ~/.ssh/authorized_keys

# Setup the vagrant user to use passwordless sudo (required for vagrant to work right)
sudo sh -c 'echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant'
sudo chmod 440 /etc/sudoers.d/vagrant
