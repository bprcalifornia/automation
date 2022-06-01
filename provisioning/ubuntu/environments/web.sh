#! /bin/bash
#
# web.sh
#
# Provisioning operations specific to the main Burbank Paranormal Research
# server (Ubuntu 22.04 LTS) web environment
#
# Ensure the common machine provisioning script (common.sh) is run first
#
# sudo chmod +x ./web.sh
#
# NOTE: superuser commands still use "sudo" so this script can be run under a
# non-root account even after initial provisioning

# Outputs a line to STDOUT
#
# Ex: output_line "Installing common packages..."
output_line() {
    echo "[PROVISION] $1"
}

# Installs certbot with Let's Encrypt so we can manage HTTPS certs
# https://letsencrypt.org/getting-started/
# https://certbot.eff.org/instructions?ws=nginx&os=ubuntufocal
#
# Ex: install_certbot
install_certbot() {
    # snap should be pre-installed; if not, see https://snapcraft.io/docs/installing-snap-on-ubuntu
    
    # install and refresh snap core
    sudo snap install core
    sudo snap refresh core

    # remove any default OS certbot package(s)
    sudo apt-get remove certbot

    # install certbot itself
    sudo snap install --classic certbot

    # add a certbot symlink to the user binary directory so it's in PATH by default
    sudo ln -s /snap/bin/certbot /usr/bin/certbot

    # certbot is now installed so we should generate and configure our cert(s)
    # for Nginx later on in one of two ways:
    #
    # 1. Automatic: sudo certbot --nginx
    # 2. Manual: sudo certbot certonly --nginx
}

# Install certbot
output_line "Installing Certbot so we can use Let's Encrypt for HTTPS certs..."
install_certbot
output_line "Finished installing Certbot"