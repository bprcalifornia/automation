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

# new non-root admin user (sudo-er) and group data
ADMIN_USER="bpr"
ADMIN_GROUP="bpr"
ADMIN_PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKW4lF6mkrzLOBG9be5adUeIveBis9X4GrEcyTYBEasi matthewfritz@Matthews-MacBook-Pro.local"

# Outputs a line to STDOUT
#
# Ex: output_line "Installing common packages..."
output_line() {
    echo "[PROVISION] $1"
}

# Provisions a new admin account
#
# Ex: add_admin_account user group user-public-key
add_admin_account() {
    sudo addgroup $2 # add the group first

    # create the user non-interactively (no prompt for GECOS information), add
    # to the new group, and disable password-based auth
    sudo adduser --gecos "" --disabled-password --ingroup $2 $1

    # add the new user to the sudoers group
    # https://askubuntu.com/a/168289
    sudo usermod -a -G sudo $1

    # add the SSH data
    local new_home_dir="/home/$1"
    local ssh_dir="$new_home_dir/.ssh"
    sudo mkdir -p $ssh_dir

    # add the necessary public key for this user
    local authorized_keys_file="$ssh_dir/authorized_keys"
    sudo touch $authorized_keys_file
    sudo echo "$ADMIN_PUBLIC_KEY" >> $authorized_keys_file

    # change the ownership of everything in the new home directory to the new user/group
    sudo chown -hR $1:$2 $new_home_dir

    # update the permissions on the directories and file(s)
    sudo chmod 755 $new_home_dir
    sudo chmod 700 $ssh_dir
    sudo chmod 600 $authorized_keys_file
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

# Install miscellaneous packages
#
# wget: simple file retrieval tool
# libssl-dev: OpenSSL development libraries
# net-tools: networking tools for debugging/analysis
output_line "Installing miscellaneous packages..."
sudo apt-get -y install wget libssl-dev net-tools
output_line "Finished installing miscellaneous packages"

# Add a new non-root admin account
output_line "Adding non-root admin account ($ADMIN_USER)..."
add_admin_account $ADMIN_USER $ADMIN_GROUP $ADMIN_PUBLIC_KEY
output_line "Finished adding non-root admin account ($ADMIN_USER)"

output_line "Finished common machine provisioning"