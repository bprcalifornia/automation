#! /bin/bash
#
# site-control.sh
#
# Nginx site control operations specific to the main Burbank Paranormal Research
# server (Ubuntu 22.04 LTS) web environment
#
# sudo chmod +x ./site-control.sh
#
# NOTE: superuser commands still use "sudo" so this script can be run under a
# non-root account even after initial provisioning

# Absolute path to this script's directory
# https://stackoverflow.com/a/11114547
SCRIPT_DIR=$(dirname $(realpath "$0"))

# Nginx-specific properties
NGINX_DIR="/etc/nginx"
NGINX_LOG_DIR="/var/log/nginx"
SITES_AVAILABLE_DIR="${NGINX_DIR}/sites-available"
SITES_ENABLED_DIR="${NGINX_DIR}/sites-enabled"

# Nginx web account information
WEB_ACCOUNT_USER="www"
WEB_ACCOUNT_GROUP="www"
WEB_ACCOUNT_DIR="/var/www"

# SSL PKI properties
SSL_CERT_DIR="/etc/ssl/certs"
SSL_KEY_DIR="/etc/ssl/private"

display_help() {
    local script_name=$(basename "$0")
    echo "Usage: ${script_name} [operation] [arguments]"
    echo
    echo "Operation can be one of the following:"
    echo
    echo "   add-site [server_name] [--regular|--laravel]"
    echo "   add-site-redirect [server_name] [redirect_host]"
    echo "   check-site [server_name]"
    echo "   disable-site [server_name]"
    echo "   enable-site [server_name]"
    echo "   add-ssl-cert [server_name] [--local|--production]"
    echo "   remove-ssl-cert [server_name]"
    echo "   replace-ssl-cert [server_name] [--local|--production]"
    echo "   help"
    echo
    echo "Examples:"
    echo
    echo "   add-site example.com"
    echo "   add-site example.com --regular"
    echo "   add-site example.com --laravel"
    echo "   add-site-redirect example.com www.example.com"
    echo "   check-site example.com"
    echo "   disable-site example.com"
    echo "   enable-site example.com"
    echo "   add-ssl-cert example.com"
    echo "   add-ssl-cert example.com --local"
    echo "   add-ssl-cert example.com --production"
    echo "   remove-ssl-cert example.com"
    echo "   replace-ssl-cert example.com"
    echo "   replace-ssl-cert example.com --local"
    echo "   replace-ssl-cert example.com --production"
}

# Outputs an error line to STDOUT
#
# Ex: error_line "Cannot change site"
error_line() {
    echo "[ERROR] $1"
}

# Outputs an error line to STDOUT followed by "Exiting" and exits immediately
# with the specified exit status code
#
# Ex: fatal_line "Site modification failed" $E_NO_SITE
fatal_line() {
    error_line "$1"
    error_line "Exiting"
    exit $2
}

# Outputs a line to STDOUT
#
# Ex: output_line "Installing new site..."
output_line() {
    echo "[INFO] $1"
}

# Reloads the Nginx service configuration
#
# Ex: reload_nginx
reload_nginx() {
    output_line "Reloading Nginx service configuration..."
    sudo systemctl reload nginx
    output_line "Reloaded Nginx service configuration"
}

# Adds a new site to Nginx. If the second parameter is non-empty, a different
# site template will be used other than the default.
#
# Ex: add_site "example.com"
# Ex: add_site "example.com" "laravel"
add_site() {
    # set variables for readability
    local server_name="$1"
    if [ -z "$server_name" ]; then
        error_line "Site name is required. Skipping"
        return
    fi

    output_line "Adding site \"${server_name}\" to Nginx..."

    # set the template
    local template_type=""
    if [ ! -z "$2" ]; then
        template_type="$2"
    fi

    # figure out the template depending on whether this is a regular or Laravel
    # site
    local template_file=""
    case "$template_type" in
        laravel)
            # use the Laravel site template
            output_line "Using Laravel site template"
            template_file="templates/site-template-laravel"
            ;;
        *)
            # default to the regular template
            output_line "Using default site template"
            template_file="templates/site-template"
    esac

    # copy over the template file and update all server name references; intentionally
    # prevent clobbering in case the site configuration already exists
    local site_filename="${SITES_AVAILABLE_DIR}/${server_name}"
    if [ -f "$site_filename" ]; then
        # site configuration file already exists
        error_line "Site configuration file \"${server_name}\" already exists. Skipping."
        return
    fi
    sudo cp $SCRIPT_DIR/$template_file $site_filename
    sudo perl -p -i -e "s/(\[SERVER_NAME\])/${server_name}/g" $site_filename

    # add a site-specific log directory with the proper ownership
    local site_log_dir="${NGINX_LOG_DIR}/${server_name}"
    if [ ! -d "$site_log_dir" ]; then
        sudo mkdir $site_log_dir
    fi
    sudo chown $WEB_ACCOUNT_USER $site_log_dir

    # now create the site root then set its permissions and ownership
    local site_root="${WEB_ACCOUNT_DIR}/${server_name}"
    if [ ! -d "$site_root" ]; then
        sudo mkdir -p $site_root
    fi
    sudo chmod 755 $site_root
    sudo chown $WEB_ACCOUNT_USER:$WEB_ACCOUNT_GROUP $site_root

    # add a default SSL certificate for the site so we can have HTTPS during
    # development
    add_ssl_certificate $server_name

    output_line "Added site \"${server_name}\" to Nginx successfully"
}

# Adds a new site redirect to Nginx.
#
# Ex: add_site_redirect "example.com" "www.example.com"
add_site_redirect() {
    # set variables for readability
    local server_name="$1"
    local redirect_host="$2"
    local template_file="templates/site-template-redirect"
    if [ -z "$server_name" ]; then
        error_line "Site name is required. Skipping"
        return
    fi
    if [ -z "$redirect_host" ]; then
        error_line "Redirect host name is required. Skipping"
        return
    fi

    output_line "Adding site redirect for \"${server_name}\" -> \"${redirect_host}\" to Nginx..."

    # copy over the template file and update all server and host references; intentionally
    # prevent clobbering in case the site configuration already exists
    local site_filename="${SITES_AVAILABLE_DIR}/${server_name}"
    if [ -f "$site_filename" ]; then
        # site configuration file already exists
        error_line "Site configuration file \"${server_name}\" already exists. Skipping."
        return
    fi
    sudo cp $SCRIPT_DIR/$template_file $site_filename
    sudo perl -p -i -e "s/(\[SERVER_NAME\])/${server_name}/g" $site_filename
    sudo perl -p -i -e "s/(\[REDIRECT_HOST\])/${redirect_host}/g" $site_filename

    # add a site-specific log directory with the proper ownership
    local site_log_dir="${NGINX_LOG_DIR}/${server_name}"
    if [ ! -d "$site_log_dir" ]; then
        sudo mkdir $site_log_dir
    fi
    sudo chown $WEB_ACCOUNT_USER $site_log_dir

    # add a default SSL certificate for the site so we can have HTTPS during
    # development
    add_ssl_certificate $server_name

    output_line "Added site redirect \"${server_name}\" -> \"${redirect_host}\" to Nginx successfully"
}

# Installs an SSL certificate for Nginx. If the second parameter is "production",
# then certbot and Let's Encrypt will be used for generating the cert; otherwise,
# openssl will be used to generate a self-signed cert.
#
# Ex: add_ssl_certificate "example.com"
# Ex: add_ssl_certificate "example.com" "production"
#
# https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs#generate-a-self-signed-certificate
# https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-22-04
add_ssl_certificate() {
    # set variables for readability
    local server_name="$1"
    local cert_type="local"
    local cert_file="${SSL_CERT_DIR}/${server_name}.crt"
    local key_file="${SSL_KEY_DIR}/${server_name}.key"
    if [ ! -z "$2" ]; then
        cert_type="$2"
    fi

    # ensure we have a site name
    if [ -z "$server_name" ]; then
        error_line "Site name is required. Skipping"
        return
    fi

    output_line "Adding SSL certificate for site \"${server_name}\"..."

    # prevent clobbering in case the cert files already exists
    sudo stat $key_file > /dev/null 2>&1 # we just care about the status code for $? and don't want to show STDOUT/STDERR
    if [[ -f "$cert_file" && "$?" -eq "0" ]]; then
        # certificate files already exist
        error_line "Certificate files (cert and private key) already exist. Skipping."
        return
    fi

    # generate the certificate
    case "$cert_type" in
        production)
            # TODO: use certbot to generate and install the certificate
            ;;
        *)
            # use openssl to generate a new X.509 self-signed certificate
            output_line "Using openssl to generate a self-signed certificate"
            sudo openssl req -newkey rsa:2048 -nodes -keyout $key_file -x509 -days 365 -out $cert_file
    esac

    output_line "Successfully added SSL certificate for site \"${server_name}\""
}

# Checks Nginx configuration for a site
#
# Ex: check_site "example.com"
check_site() {
    # set variables for readability
    local server_name="$1"
    if [ -z "$server_name" ]; then
        error_line "Site name is required. Skipping"
        return
    fi

    # does the site configuration file exist?
    if [ ! -f "${SITES_AVAILABLE_DIR}/${server_name}" ]; then
        # if it doesn't exist, just return since something that does not exist
        # obviously will not be enabled either
        output_line "Site configuration file \"${server_name}\" does not exist"
        return
    fi

    # site config file exists, so check whether it is enabled with a symlink
    output_line "Site configuration file \"${server_name}\" exists"
    if [ -L "${SITES_ENABLED_DIR}/${server_name}" ]; then
        if [ -e "${SITES_ENABLED_DIR}/${server_name}" ]; then
            output_line "Site configuration is enabled"
        else
            output_line "Site configuration is not enabled (symlink exists but its target does not exist)"
        fi
    else
        output_line "Site configuration is not enabled (symlink does not exist)"
    fi

    # now run the check the overall Nginx configuration
    output_line "Checking overall Nginx configuration..."
    sudo nginx -t
}

# Disables a site in Nginx
#
# Ex: disable_site "example.com"
disable_site() {
    # set variables for readability
    local server_name="$1"
    if [ -z "$server_name" ]; then
        error_line "Site name is required. Skipping"
        return
    fi

    # remove the site and reload the configuration
    output_line "Disabling site \"${server_name}\"..."
    sudo rm $SITES_ENABLED_DIR/$server_name
    reload_nginx
    output_line "Successfully disabled site \"${server_name}\""
}

# Enables a site in Nginx
#
# Ex: enable_site "example.com"
enable_site() {
    # set variables for readability
    local server_name="$1"
    if [ -z "$server_name" ]; then
        error_line "Site name is required. Skipping"
        return
    fi

    # enable the site and reload the configuraiton
    output_line "Enabling site \"${server_name}\"..."
    sudo ln -s $SITES_AVAILABLE_DIR/$server_name $SITES_ENABLED_DIR/$server_name
    reload_nginx
    output_line "Successfully enabled site \"${server_name}\""
}

# Removes an SSL certificate from Nginx
#
# Ex: remove_ssl_certificate "example.com"
remove_ssl_certificate() {
    # set variables for readability
    local server_name="$1"
    if [ -z "$server_name" ]; then
        error_line "Site name is required. Skipping"
        return
    fi

    # remove the certificate and key files
    output_line "Removing SSL certificate for site \"${server_name}\"..."
    sudo rm "${SSL_CERT_DIR}/${server_name}.crt"
    sudo rm "${SSL_KEY_DIR}/${server_name}.key"
    output_line "Successfully removed SSL certificate for site \"${server_name}\""
}

# Replaces an SSL certificate for Nginx. If the second parameter is "production",
# then certbot and Let's Encrypt will be used for generating the cert; otherwise,
# openssl will be used to generate a self-signed cert.
#
# The existing cert will be removed first if it exists.
#
# Ex: replace_ssl_certificate "example.com"
# Ex: replace_ssl_certificate "example.com" "production"
replace_ssl_certificate() {
    # set variables for readability
    local server_name="$1"
    local cert_type="local"
    if [ ! -z "$2" ]; then
        cert_type="$2"
    fi

    # ensure we have a site name
    if [ -z "$server_name" ]; then
        error_line "Site name is required. Skipping"
        return
    fi

    # remove the certificate first
    remove_ssl_certificate $server_name

    # now add a new certificate
    add_ssl_certificate $server_name $cert_type
}

# Figure out which control operation to perform
if [ -z "$1" ]; then
    # no arguments so just display the help screen
    display_help
    exit
fi
case "$1" in
    add-site)
        # add a new Nginx site
        site_type=""
        if [ ! -z "$3" ]; then
            case "$3" in
                --laravel)
                    site_type="laravel"
                    ;;
                *)
                    site_type="regular"
            esac
        fi
        add_site "$2" "${site_type}"
        ;;
    add-site-redirect)
        # add a new Nginx redirect site
        add_site_redirect "$2" "$3"
        ;;
    check-site)
        # checks the configuration of an Nginx site
        check_site "$2"
        ;;
    disable-site)
        # disable an Nginx site
        disable_site "$2"
        ;;
    enable-site)
        # enable an Nginx site
        enable_site "$2"
        ;;
    add-ssl-cert)
        # add an SSL cert for a site
        cert_type=""
        if [ ! -z "$3" ]; then
            case "$3" in
                --production)
                    cert_type="production"
                    ;;
                *)
                    cert_type="local"
            esac
        fi
        add_ssl_certificate "$2" "${cert_type}"
        ;;
    remove-ssl-cert)
        # remove an SSL cert for a site
        remove_ssl_certificate "$2"
        ;;
    replace-ssl-cert)
        # replace an SSL cert for a site
        cert_type=""
        if [ ! -z "$3" ]; then
            case "$3" in
                --production)
                    cert_type="production"
                    ;;
                *)
                    cert_type="local"
            esac
        fi
        replace_ssl_certificate "$2" "${cert_type}"
        ;;
    help|*)
        # help command or unrecognized command
        display_help
esac