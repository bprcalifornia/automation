# BPR Automation

Automated scripts and tools related to [Burbank Paranormal Research](https://github.com/bprcalifornia) IT workflows and processes.

## Table of Contents

* [Overview](#overview)
* [Machine Provisioning](#machine-provisioning)
    * [Main Server Machine](#main-server-machine)
* [Environments](#environments)
    * [Common Environment](#common-environment)
        * [Common Environment Provisioning](#common-environment-provisioning)
    * [Web Environment](#web-environment)
        * [Web Environment Provisioning](#web-environment-provisioning)
    * [Database Environment](#database-environment)
        * [Database Environment Provisioning](#database-environment-provisioning)
* [Nginx Automation](#nginx-automation)
    * [Site Control Tool](#site-control-tool)

## Overview

BPR uses Ubuntu (currently [Ubuntu 22.04 LTS](https://releases.ubuntu.com/22.04/)) as the underlying OS for all of its hosted machines.

All shell scripts (files ending in `.sh`) are written in Bash and need to be marked with the executable (`+x`) bit before they are runnable.

## Machine Provisioning

### Main Server Machine

The main server is provisioned with the [`provisioning/ubuntu/main-server.sh`](provisioning/ubuntu/main-server.sh) script. This will create and configure the [Common](#common-environment), [Web](#web-environment), and [Database](#database-environment) environments.

## Environments

The environment-specific provisioning scripts live within the [`provisioning/ubuntu/environments`](provisioning/ubuntu/environments) directory.

### Common Environment

Script: [`common.sh`](provisioning/ubuntu/environments/common.sh)

The _Common Environment_ provides the base dependencies and configuration for all other environments.

This is the first script that should be run before a specific environment is provisionined.

#### Common Environment Provisioning

The provisioning script installs the following packages via `apt-get`:

* Development / Building: [`build-essential`](https://packages.ubuntu.com/jammy/build-essential)
* OpenSSH: [`openssh-client`](https://packages.ubuntu.com/jammy/openssh-client), [`openssh-server`](https://packages.ubuntu.com/jammy/openssh-server)
* Network Tools: [`net-tools`](https://packages.ubuntu.com/jammy/net-tools), [`wget`](https://packages.ubuntu.com/jammy/wget)
* OpenSSL: [`libssl-dev`](https://packages.ubuntu.com/jammy/libssl-dev)

NOTE: the `build-essential` package is what includes `git`, `perl`, `make`, etc. as part of its [`dpkg-dev`](https://packages.ubuntu.com/jammy/dpkg-dev) dependency.

The script performs the following configuration operations:

* Adds a non-root administrative user with `sudo` capabilities
* Allows the new non-root user to access the machine via SSH
* Removes the password from and locks the `root` account
* Disables `root` login over SSH
* Disables password-based login over SSH (for our purposes, we only want to use key-based auth)

### Web Environment

Script: [`web.sh`](provisioning/ubuntu/environments/web.sh)

The _Web Environment_ provides everything related to processing and serving data both internally (to our staff and clients) and externally (to the public) over the web.

All of the BPR websites, web applications, and data that anyone accesses are served within this environment.

#### Web Environment Provisioning

The provisioning script installs the following packages via `snap`:

* Core: [`core`](https://snapcraft.io/install/core/ubuntu)
* Certbot: [`certbot`](https://snapcraft.io/install/certbot/ubuntu)

NOTE: `certbot` is used to enable HTTPS in production through [Let's Encrypt](https://letsencrypt.org/getting-started/); `openssl` is used to enable HTTPS in the development environment(s).

The provisioning script installs the following packages via `apt-get`:

* [PHP 8.1](https://www.php.net/releases/8.1/en.php)
    * [`php8.1`](https://packages.ubuntu.com/jammy/php8.1)
    * [`php8.1-cli`](https://packages.ubuntu.com/jammy/php8.1-cli)
    * [`php8.1-common`](https://packages.ubuntu.com/jammy/php8.1-common)
    * [`php8.1-mysql`](https://packages.ubuntu.com/jammy/php8.1-mysql)
    * [`php8.1-zip`](https://packages.ubuntu.com/jammy/php8.1-zip)
    * [`php8.1-gd`](https://packages.ubuntu.com/jammy/php8.1-gd)
    * [`php8.1-mbstring`](https://packages.ubuntu.com/jammy/php8.1-mbstring)
    * [`php8.1-curl`](https://packages.ubuntu.com/jammy/php8.1-curl)
    * [`php8.1-xml`](https://packages.ubuntu.com/jammy/php8.1-xml)
    * [`php8.1-bcmath`](https://packages.ubuntu.com/jammy/php8.1-bcmath)
    * [`php8.1-fpm`](https://packages.ubuntu.com/jammy/php8.1-fpm)
* [Nginx](https://docs.nginx.com/nginx/admin-guide/web-server/): [`nginx`](https://packages.ubuntu.com/jammy/nginx)
* [Redis](https://redis.io): [`redis-server`](https://packages.ubuntu.com/jammy/redis-server)

The provisioning installs the following packages via `php`:

* [Composer](https://getcomposer.org/): PHP package manager

Finally, the script performs the following configuration operations:

* Adds a non-admin web user and group named `www`
* Changes the process user for Nginx to be the new web user
* Changes the ownership information for Nginx logs, web data, document roots, etc. to the new web user with `chown`
* Configures Redis to be managed and monitored under `systemd` so `systemctl` can be used

### Database Environment

Script: [`db.sh`](provisioning/ubuntu/environments/db.sh)

The _Database Environment_ 

#### Database Environment Provisioning

## Nginx Automation

BPR uses Nginx to serve both its static and dynamic resources.

Everything for Nginx can be found in the [`nginx`](nginx) directory.

### Site Control Tool

Script: [`site-control.sh`](nginx/site-control.sh)