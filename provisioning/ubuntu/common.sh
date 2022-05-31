#! /bin/bash
#
# common.sh
#
# Common provisioning operations for Burbank Paranormal Research
# Ubuntu machines (currently Ubuntu 22.04 LTS)
#
# Expects the following environment variables to be set:
#
#    PROVISION_USER (the new non-root admin user account to add)
#    PROVISION_GROUP (the new group for the non-root admin user account)
#    PROVISION_PUBLIC_KEY (the SSH public key for the new non-root admin user account)
#
# NOTE: superuser commands still use "sudo" so this script can be run under a
# non-root account even after initial provisioning
#
# NOTE: this script will lock down the root account, disable password-based
# authentication, and it will also remove the root public key; the only way to
# access the root account will be when you are already SSH-ed into the machine
#
# sudo chmod +x ./common.sh

# Non-success exit code: missing environment variable(s)
E_MISSING_ENV=1

# Outputs an error line to STDOUT
#
# Ex: error_line "Missing environment variable"
error_line() {
    echo "[ERROR] $1"
}

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
    # https://askubuntu.com/a/94067
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
    sudo echo "$3" >> $authorized_keys_file

    # change the ownership of everything in the new home directory to the new user/group
    sudo chown -hR $1:$2 $new_home_dir

    # update the permissions on the directories and file(s)
    sudo chmod 755 $new_home_dir
    sudo chmod 700 $ssh_dir
    sudo chmod 600 $authorized_keys_file
}

# Locks down a user account. This removes the public key from the specified account,
# removes its local password, then subsequently locks it.
#
# Ex: lock_down_account user public-key-to-remove
lock_down_account() {
    # figure out the home directory depending on the account
    local home_dir="/home/$1"
    if [ "$1" == "root" ]; then
        home_dir="/root"
    fi

    # remove the public key from the authorized_keys file since we do not want to
    # allow the non-root admin account and the root account to share the same key
    local authorized_keys_file="$home_dir/.ssh/authorized_keys"
    sudo sed -i "/$2/d" $authorized_keys_file

    # remove the password from the account and lock it to prevent authentication
    # with a local password
    # https://askubuntu.com/a/104140
    sudo passwd -dl $1
}

# Locks down SSH. This disables direct root login and disables password-based
# authentication entirely.
#
# Ex: lock_down_ssh
lock_down_ssh() {
    # disable root login over SSH
    local sshd_config_file="/etc/ssh/sshd_config"
    sudo perl -p -i -e "s/PermitRootLogin yes/PermitRootLogin no/g" $sshd_config_file

    # disable password-based login over SSH
    sudo perl -p -i -e "s/PasswordAuthentication yes/PasswordAuthentication no/g" $sshd_config_file

    # reload the sshd configuration via systemctl so the changes take effect
    output_line "Reloading sshd service configuration..."
    sudo systemctl reload sshd
    output_line "Reloaded sshd service configuration"
}

# Check our environment variables first before proceeding
HAS_ERROR=0
if [ -z $PROVISION_USER ]; then
    error_line "Environment variable PROVISION_USER is not set"
    HAS_ERROR=1
fi
if [ -z $PROVISION_GROUP ]; then
    error_line "Environment variable PROVISION_GROUP is not set"
    HAS_ERROR=1
fi
if [ -z $PROVISION_PUBLIC_KEY ]; then
    error_line "Environment variable PROVISION_PUBLIC_KEY is not set"
    HAS_ERROR=1
fi

# If any errors occurred, exit with a non-zero status
if [ $HAS_ERROR -eq 1 ]; then
    error_line "Exiting with error status $E_MISSING_ENV"
    exit $E_MISSING_ENV
fi

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
output_line "Adding non-root admin account ($PROVISION_USER)..."
add_admin_account $PROVISION_USER $PROVISION_GROUP $PROVISION_PUBLIC_KEY
output_line "Finished adding non-root admin account ($PROVISION_USER)"

# Lock down the root account
output_line "Locking down root account..."
lock_down_account root $PROVISION_PUBLIC_KEY
output_line "Finished locking down root account"

# Lock down SSH
output_line "Locking down SSH..."
lock_down_ssh
output_line "Finished locking down SSH"

output_line "Finished common machine provisioning"