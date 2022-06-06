#! /bin/bash
#
# db.sh
#
# Provisioning operations specific to the main Burbank Paranormal Research
# server (Ubuntu 22.04 LTS) database environment
#
# sudo chmod +x ./db.sh
#
# NOTE: superuser commands still use "sudo" so this script can be run under a
# non-root account even after initial provisioning
#
# https://www.digitalocean.com/community/tutorials/how-to-install-mariadb-on-ubuntu-22-04

# Outputs an error line to STDOUT
#
# Ex: error_line "Cannot provision"
error_line() {
    echo "[ERROR] $1"
}

# Outputs an error line to STDOUT followed by "Exiting" and exits immediately
# with the specified exit status code
#
# Ex: fatal_line "Common provisioning failed" $E_NO_COMMON
fatal_line() {
    error_line "$1"
    error_line "Exiting"
    exit $2
}

# Outputs a line to STDOUT
#
# Ex: output_line "Installing common packages..."
output_line() {
    echo "[PROVISION] $1"
}

# Installs MySQL (this uses MariaDB as the server distribution); this will
# also display output regarding an installation command that must be run
# manually.
#
# Ex: install_mysql
install_mysql() {
    sudo apt-get install -y mariadb-server

    # display the command that will need to be run manually
    echo
    output_line "Make sure you run the following command to set up your new MySQL instance:"
    output_line "   sudo mysql_secure_installation"
    output_line
    output_line "Make sure you disallow root login remotely to ensure that the root account"
    output_line "can only be accessed from the same local machine"
    output_line
}

# Install MySQL (MariaDB)
output_line "Installing MySQL..."
install_mysql
output_line "Finished installing MySQL"