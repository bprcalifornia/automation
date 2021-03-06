#! /bin/bash
#
# main-server.sh
#
# Provisioning operations specific to the main Burbank Paranormal Research
# server (Ubuntu 22.04 LTS)
#
# The following scripts will be run in this order:
#   environments/
#      common.sh (common environment provisioning)
#      web.sh (web environment provisioning)
#      db.sh (database environment provisioning)
#
# NOTE: superuser commands still use "sudo" so this script can be run under a
# non-root account even after initial provisioning

# Exit status code when common provisioning operations fail
E_NO_COMMON=81

# Exit status code when web environment provisioning fails
E_NO_WEB=82

# Exit status code when database environment provisioning fails
E_NO_DB=83

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

# Begin provisioning the specific environments
pushd environments

# Perform the common machine provisioning
output_line "Performing common machine provisioning operations..."
sudo chmod +x ./common.sh
./common.sh
if [ ! "$?" -eq "0" ]; then
    # something failed with the common provisioning so exit immediately
    popd
    fatal_line "Common machine provisioning failed" $E_NO_COMMON
fi
output_line "Finished common machine provisioning operations"

# Perform the web environment provisioning
output_line "Provisioning web environment..."
sudo chmod +x ./web.sh
./web.sh
if [ ! "$?" -eq "0" ]; then
    # something failed with the web environment provisioning so exit immediately
    popd
    fatal_line "Web environment provisioning failed" $E_NO_WEB
fi
output_line "Finished provisioning web environment"

# Perform the database environment provisioning
output_line "Provisioning database environment..."
sudo chmod +x ./db.sh
./db.sh
if [ ! "$?" -eq "0" ]; then
    # something failed with the database environment provisioning so exit immediately
    popd
    fatal_line "Database environment provisioning failed" $E_NO_DB
fi
output_line "Finished provisioning database environment"

# Pop the environments directory from the stack and finish up
popd
output_line "Finished"