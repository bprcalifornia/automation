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

The _Common Environment_ is the base environment for all other environments. This script installs common packages and dependencies and configures SSH.

This is the first script that should be run before a specific environment is provisionined.

#### Common Environment Provisioning

The provisioning script installs the following packages via `apt-get`:

* Development / Building: [`build-essential`](https://packages.ubuntu.com/jammy/build-essential)
* OpenSSH: [`openssh-client`](https://packages.ubuntu.com/jammy/openssh-client), [`openssh-server`](https://packages.ubuntu.com/jammy/openssh-server)
* Network Tools: [`net-tools`](https://packages.ubuntu.com/jammy/net-tools), [`wget`](https://packages.ubuntu.com/jammy/wget)
* OpenSSL: [`libssl-dev`](https://packages.ubuntu.com/jammy/libssl-dev)

NOTE: the `build-essential` package is what includes `git`, `perl`, `make`, etc. as part of its [`dpkg-dev`](https://packages.ubuntu.com/jammy/dpkg-dev) dependency.

The script also performs the following configuration operations:

* Adds a non-root administrative user with `sudo` capabilities
* Allows the new non-root user to access the machine via SSH
* Removes the password from and locks the `root` account
* Disables `root` login over SSH
* Disables password-based login over SSH (for our purposes, we only want to use key-based auth)

### Web Environment

Script: [`web.sh`](provisioning/ubuntu/environments/web.sh)

#### Web Environment Provisioning

### Database Environment

Script: [`db.sh`](provisioning/ubuntu/environments/db.sh)

#### Database Environment Provisioning

## Nginx Automation

BPR uses Nginx to serve both its static and dynamic resources.

Everything for Nginx can be found in the [`nginx`](nginx) directory.

### Site Control Tool

Script: [`site-control.sh`](nginx/site-control.sh)