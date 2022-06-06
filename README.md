# BPR Automation

Automated scripts and tools related to [Burbank Paranormal Research](https://github.com/bprcalifornia) IT workflows and processes.

## Table of Contents

* [Overview](#overview)
* [Machine Provisioning](#machine-provisioning)
    * [Environments](#environments)
        * [Common Environment](#common-environment)
        * [Web Environment](#web-environment)
        * [Database Environment](#database-environment)
* [Nginx Automation](#nginx-automation)
    * [Site Control Tool](#site-control-tool)

## Overview

BPR uses Ubuntu (currently [Ubuntu 22.04 LTS](https://releases.ubuntu.com/22.04/)) as the underlying OS for all of its hosted machines.

All shell scripts (files ending in `.sh`) are written in Bash and need to be marked with the executable (`+x`) bit before they are runnable.

## Machine Provisioning

The main server is provisioned with the [`provisioning/ubuntu/main-server.sh`](provisioning/ubuntu/main-server.sh) script. This will create and configure the [Common](#common-environment), [Web](#web-environment), and [Database](#database-environment) environments.

### Environments

The environment-specific provisioning scripts live within the [`provisioning/ubuntu/environments`](provisioning/ubuntu/environments) directory.

#### Common Environment

Script: [`common.sh`](provisioning/ubuntu/environments/common.sh)

#### Web Environment

Script: [`web.sh`](provisioning/ubuntu/environments/web.sh)

#### Database Environment

Script: [`db.sh`](provisioning/ubuntu/environments/db.sh)

## Nginx Automation

BPR uses Nginx to serve both its static and dynamic resources.

Everything for Nginx can be found in the [`nginx`](nginx) directory.

### Site Control Tool

Script: [`site-control.sh`](nginx/site-control.sh)