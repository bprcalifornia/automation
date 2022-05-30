#! /bin/bash
#
# main-server.sh
#
# Provisioning operations specific to the main Burbank Paranormal Research
# server
#
# Ensure the common machine provisioning script (common.sh) is run first
#
# sudo chmod +x ./main-server.sh

# Outputs a line to STDOUT
#
# Ex: output_line "Installing common packages..."
output_line() {
    echo "[PROVISION] $1"
}