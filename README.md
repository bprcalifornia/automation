<div align="center">
  <p>
    <a href="https://github.com/bprcalifornia" target="_blank">
      <img src="https://raw.githubusercontent.com/bprcalifornia/.github/main/profile/img/bpr_logo.webp" alt="Burbank Paranormal Research on GitHub" title="Burbank Paranormal Research on GitHub" />
    </a>
  </p>
  <h1>BPR Automation</h1>
</div>

Automated scripts and tools related to [Burbank Paranormal Research](https://github.com/bprcalifornia) IT workflows and processes.

## Table of Contents

* [Overview](#overview)
* [Machine Hosting](#machine-hosting)
* [Machine Provisioning](#machine-provisioning)
    * [Main Server Machine](#main-server-machine)
* [Environments](#environments)
    * [Common Environment](#common-environment)
        * [Common Environment Provisioning](#common-environment-provisioning)
        * [Common Port Binds](#common-port-binds)
    * [Web Environment](#web-environment)
        * [Web Environment Provisioning](#web-environment-provisioning)
        * [Web Port Binds](#web-port-binds)
    * [Database Environment](#database-environment)
        * [Database Environment Provisioning](#database-environment-provisioning)
        * [Database Port Binds](#database-port-binds)
* [Nginx Automation](#nginx-automation)
    * [Site Control Tool](#site-control-tool)

## Overview

BPR uses Linux (currently [Ubuntu 22.04 LTS](https://releases.ubuntu.com/22.04/)) as the underlying OS for all of its hosted virtual machines.

All shell scripts (files ending in `.sh`) are written in Bash and need to be marked with the executable (`+x`) bit before they are runnable.

## Machine Hosting

The machines that BPR runs are hosted through a VPS (Virtual Private Server) provider to enable more complete control over machine behavior and environment.

Some VPS providers:

* [Linode](https://www.linode.com) - [Dedicated](https://www.linode.com/products/dedicated-cpu) / [Shared](https://www.linode.com/products/shared)
* [Digital Ocean](https://www.digitalocean.com) - [Droplets](https://www.digitalocean.com/products/droplets)
* [Amazon Web Services (AWS)](https://aws.amazon.com) - [EC2 Instances](https://aws.amazon.com/ec2)
* [Google Cloud Platform (GCP)](https://cloud.google.com) - [Compute Engine](https://cloud.google.com/compute)
* [...and many more](https://www.google.com/search?q=vps+providers)

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

#### Common Port Binds

The following TCP ports are bound (i.e. there is something listening on them):

* SSH: `22`

### Web Environment

Script: [`web.sh`](provisioning/ubuntu/environments/web.sh)

The _Web Environment_ provides everything related to processing and serving data both internally (to our staff and clients) and externally (to the public) over the web.

All of the BPR websites, web applications, and data that anyone accesses are served within this environment.

The PHP-based applications are served through Nginx using [`php-fpm`](https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/) with a Unix socket to process the PHP code.

#### Web Environment Provisioning

The provisioning script installs the following packages via [`snap`](https://snapcraft.io/):

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

The provisioning script installs the following packages via `php`:

* [Composer](https://getcomposer.org/): PHP package manager

The provisioning script installs the following tools via `bash`:

* [Node Version Manager](https://github.com/nvm-sh/nvm) (NVM): version manager for [NodeJS](https://nodejs.org/en/)

The provisioning script installs the following tools via `nvm`:

* [Most-current stable release](https://nodejs.org/en/download/current/) of NodeJS

The provisioning script installs the following packages via `npm`:

* [Yarn](https://yarnpkg.com/): NodeJS package manager replacement for NPM

Finally, the script performs the following configuration operations:

* Adds a non-admin web user and group named `www`
* Changes the process user for Nginx to be the new web user
* Changes the ownership information for Nginx logs, web data, document roots, etc. to the new web user with `chown`
* Configures Redis to be managed and monitored under `systemd` so `systemctl` can be used

#### Web Port Binds

The following TCP ports are bound (i.e. there is something listening on them):

* HTTP: `80`
* HTTPS: `443`
* Redis: `6379` (`localhost`-only bind to prevent remote connections)

### Database Environment

Script: [`db.sh`](provisioning/ubuntu/environments/db.sh)

The _Database Environment_ provides everything related to the structure, storage, retrieval, and manipulation of data within the BPR databases.

BPR uses [MariaDB](https://mariadb.org/) instead of [MySQL](https://www.mysql.com/) (as a drop-in replacement) for its relational (RDBMS) data.

#### Database Environment Provisioning

The provisioning script installs the following packages via `apt-get`:

* MariaDB: [`mariadb-server`](https://packages.ubuntu.com/jammy/mariadb-server)

The script also informs the user that they need to perform a secure MySQL installation manually with `sudo mysql_secure_installation`.

We perform the following configuration actions when prompted during the secure installation:

* Allow standard logins for `root` (i.e. **DO NOT** switch to `unix_socket` authentication)
* Set an actual password for `root`
    * This ensures that merely having access to the underlying OS `root` account does not also grant passwordless access to the MariaDB `root` account
* Remove anonymous users
* Remove the `test` database
* Disable remote logins for `root` so it is `localhost`-only via its `GRANT` clause
* Reload the privilege tables

Similarly to what we do during the [common environment provisioning](#common-environment) regarding adding an OS non-root admin user, we will add a non-root DB admin:

1. Authenticate into MariaDB (entering your new `root` DB password when prompted): `mysql -u root -p`
2. Execute the following statements to create a `localhost`-only [administrative account that can control everything](https://www.digitalocean.com/community/tutorials/how-to-create-a-new-user-and-grant-permissions-in-mysql) (and also create additional accounts and grant privileges):

```
# replace [ADMIN_USERNAME] with the user account name to create and replace
# [ADMIN_PASSWORD] with the password to assign to the new account

CREATE USER '[ADMIN_USERNAME]'@localhost IDENTIFIED BY '[ADMIN_PASSWORD]';
GRANT ALL PRIVILEGES ON *.* TO '[ADMIN_USERNAME]'@localhost WITH GRANT OPTION;
```

For example, to create a new `db_admin` user with the password `adminpw` we would execute the following statements:

```
CREATE USER 'db_admin'@localhost IDENTIFIED BY 'adminpw';
GRANT ALL PRIVILEGES ON *.* TO 'db_admin'@localhost WITH GRANT OPTION;
```

3. Execute the following statement to flush the privilege tables and activate the new account:

```
FLUSH PRIVILEGES;
```

4. Disconnect from the MariaDB instance via the `mysql` CLI: `exit;`

#### Database Port Binds

The following TCP ports are bound (i.e. there is something listening on them):

* MariaDB (MySQL): `3306`

## Nginx Automation

BPR uses Nginx to serve both its static and dynamic resources.

Everything for Nginx can be found in the [`nginx`](nginx) directory.

### Site Control Tool

Script: [`site-control.sh`](nginx/site-control.sh)