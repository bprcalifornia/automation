#! /bin/bash
#
# web.sh
#
# Provisioning operations specific to the main Burbank Paranormal Research
# server (Ubuntu 22.04 LTS) web environment
#
# sudo chmod +x ./web.sh
#
# NOTE: superuser commands still use "sudo" so this script can be run under a
# non-root account even after initial provisioning
#
# https://www.digitalocean.com/community/tutorials/how-to-install-php-8-1-and-set-up-a-local-development-environment-on-ubuntu-22-04
# https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-on-ubuntu-22-04
# https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-laravel-with-nginx-on-ubuntu-22-04
# https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-redis-on-ubuntu-22-04

# New web user account information; these will also modify some of the Nginx settings
WEB_ACCOUNT_USER="www"
WEB_ACCOUNT_GROUP="www"
WEB_ACCOUNT_DIR="/var/www"

# Name of the PHP version when installing packages and the relative package names
PHP_VERSION_NAME="php8.1"
PHP_VERSION_PACKAGES="cli common mysql zip gd mbstring curl xml bcmath fpm"

# Nginx-specific properties
NGINX_LOG_DIR="/var/log/nginx"

# Outputs a line to STDOUT
#
# Ex: output_line "Installing common packages..."
output_line() {
    echo "[PROVISION] $1"
}

# Adds the web user account and creates the web document root
#
# Ex: add_web_account
add_web_account() {
    # add the group first
    sudo addgroup $WEB_ACCOUNT_GROUP

    # create the user non-interactively (no prompt for GECOS information), add
    # to the new group, and disable password-based auth
    # https://askubuntu.com/a/94067
    sudo adduser --gecos "" --disabled-password --ingroup $WEB_ACCOUNT_GROUP $WEB_ACCOUNT_USER

    # remove the password from the account and lock it to prevent authentication
    # with a local password
    # https://askubuntu.com/a/104140
    sudo passwd -dl $WEB_ACCOUNT_USER

    # add the default web root (if it doesn't exist) and change the permissions and ownership
    if [ ! -d "$WEB_ACCOUNT_DIR" ]; then
        sudo mkdir -p $WEB_ACCOUNT_DIR
    fi

    # set the web root ownership
    sudo chown -hR $WEB_ACCOUNT_USER:$WEB_ACCOUNT_GROUP $WEB_ACCOUNT_DIR

    # setgid (2) on the web root directory so the web server can serve files
    # created inside the directory based on the group if necessary (along with
    # the proper rwxr-xr-x perms that become rwxr-sr-x)
    sudo chmod 2755 $WEB_ACCOUNT_DIR
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

# Installs Composer and links it properly so it is available in PATH
#
# Ex: install_composer
install_composer() {
    # write the Composer setup script to /tmp
    curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php

    # execute the setup script, install Composer in /usr/local/bin, and then
    # remove the script immediately
    sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
    rm /tmp/composer-setup.php
}

# Installs Nginx
#
# Ex: install_nginx
install_nginx() {
    # install the base Nginx distribution
    sudo apt-get install -y nginx

    # change the user under which the Nginx process runs
    sudo perl -p -i -e "s/user www-data;/user ${WEB_ACCOUNT_USER};/g" /etc/nginx/nginx.conf

    # change the ownership on the default Nginx log files
    sudo chown $WEB_ACCOUNT_USER $NGINX_LOG_DIR/*.log

    # change the ownership on the web directory again to take any default web
    # document structure from Nginx into account
    sudo chown -hR $WEB_ACCOUNT_USER:$WEB_ACCOUNT_GROUP $WEB_ACCOUNT_DIR

    # restart the Nginx service so our changes take effect immediately; we have
    # to restart instead of reload since the process user has changed
    sudo systemctl restart nginx
}

# Installs PHP along with some useful extensions
#
# Ex: install_php
install_php() {
    sudo apt-get install -y --no-install-recommends $PHP_VERSION_NAME

    # packages will be installed as ${PHP_VERSION_NAME}-${package_name}
    # Ex: apt-get install -y php8.1-cli php8.1-common ...
    local install_command="apt-get install -y"
    for package_name in $PHP_VERSION_PACKAGES; do
        install_command="${install_command} ${PHP_VERSION_NAME}-${package_name}"
    done
    sudo $install_command
}

# Installs Redis
#
# Ex: install_redis
install_redis() {
    sudo apt-get install -y redis-server

    # allow systemd (systemctl) to manage Redis
    sudo perl -p -i -e "s/^(supervised no)$/supervised systemd/g" /etc/redis/redis.conf

    # now restart the Redis service
    sudo systemctl restart redis
}

# Install certbot
output_line "Installing Certbot so we can use Let's Encrypt for HTTPS certs..."
install_certbot
output_line "Finished installing Certbot"

# Create the web user and create the web document root
output_line "Adding web user account..."
add_web_account
output_line "Finished adding web user account"

# Install PHP along with some useful extensions
output_line "Installing PHP along with some useful extensions..."
install_php
output_line "Finished installing PHP"

# Install Composer and link it in the PATH
output_line "Installing Composer..."
install_composer
output_line "Finished installing Composer"

# Install Nginx
output_line "Installing Nginx..."
install_nginx
output_line "Finished installing Nginx"

# Install Redis
output_line "Installing Redis..."
install_redis
output_line "Finished installing Redis"