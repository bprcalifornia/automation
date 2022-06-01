#! /bin/bash
#
# db.sh
#
# Provisioning operations specific to the main Burbank Paranormal Research
# server (Ubuntu 22.04 LTS) database environment
#
# Ensure the common machine provisioning script (common.sh) is run first
#
# sudo chmod +x ./db.sh
#
# NOTE: superuser commands still use "sudo" so this script can be run under a
# non-root account even after initial provisioning

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