#! /bin/bash
#
# main-server.sh
#
# Provisioning operations specific to the main Burbank Paranormal Research
# server (Ubuntu 22.04 LTS)
#
# The following scripts will be run in this order:
#   common.sh (common machine provisioning)
#   environments/
#      web.sh (web environment provisioning)
#
# NOTE: superuser commands still use "sudo" so this script can be run under a
# non-root account even after initial provisioning

# Exit status code when common provisioning operations fail
E_NO_COMMON=81

# Exit status code when web environment provisioning fails
E_NO_WEB=82

# Outputs an error line to STDOUT
#
# Ex: error_line "Cannot provision"
error_line() {
    echo "[ERROR] $1"
}

# Outputs a line to STDOUT
#
# Ex: output_line "Installing common packages..."
output_line() {
    echo "[PROVISION] $1"
}

# Perform the common machine provisioning
output_line "Performing common machine provisioning operations..."
sudo chmod +x ./common.sh
./common.sh
if [ ! "$?" -eq "0" ]; then
    # something failed with the common provisioning so exit immediately
    error_line "Common machine provisioning failed"
    error_line "Exiting"
    exit $E_NO_COMMON
fi
output_line "Finished common machine provisioning operations"

# Perform the web environment provisioning
output_line "Provisioning web environment..."
pushd environments
sudo chmod +x ./web.sh
./web.sh
if [ ! "$?" -eq "0" ]; then
    # something failed with the web environment provisioning so exit immediately
    error_line "Web environment provisioning failed"
    error_line "Exiting"
    popd
    exit $E_NO_WEB
fi
output_line "Finished provisioning web environment"

# Pop the environments directory from the stack and finish up
popd
output_line "Finished"