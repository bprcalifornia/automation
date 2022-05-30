#! /bin/bash
#
# common.sh
#
# Common provisioning operations for Burbank Paranormal Research
# Ubuntu machines (currently Ubuntu 22.04 LTS)
#
# NOTE: superuser commands still use "sudo" so this script can be run under a
# non-root account even after initial provisioning
#
# sudo chmod +x ./common.sh

# Outputs a line to STDOUT
#
# Ex: output_line "Installing common packages..."
output_line() {
    echo "[PROVISION] $1"
}

output_line "Beginning common machine provisioning..."

# Update the package list(s)
output_line "Updating package list(s)..."
sudo apt-get -y update
output_line "Finished updating package list(s)"

# Upgrade any packages
output_line "Upgrading package(s) if necessary..."
sudo apt-get -y upgrade
output_line "Finished upgrading package(s)"

# Install common development tools (git, gcc, make, etc)
# https://askubuntu.com/a/24198
output_line "Installing common development tools..."
sudo apt-get -y install build-essential
output_line "Finished installing common development tools"

# Install OpenSSH tools
output_line "Installing OpenSSH tools..."
sudo apt-get -y install openssh-client openssh-server
output_line "Finished installing OpenSSH tools"

# Install miscellaneous tools
# wget: simple file retrieval tool
# net-tools: networking tools for debugging/analysis
output_line "Installing miscellaneous tools..."
sudo apt-get -y wget net-tools
output_line "Finished installing miscellaneous tools"

output_line "Finished common machine provisioning"