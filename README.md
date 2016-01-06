# insserv_override

[![Build Status](https://travis-ci.org/smoeding/puppet-insserv_override.svg?branch=master)](https://travis-ci.org/smoeding/puppet-insserv_override)
[![Puppet Forge](http://img.shields.io/puppetforge/v/stm/insserv_override.svg)](https://forge.puppetlabs.com/stm/insserv_override)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with gai](#setup)
* [What insserv_override affects](#what-insserv_override-affects)
* [Setup requirements](#setup-requirements)
* [Beginning with insserv_override](#beginning-with-insserv_override)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Manage override files for LSB `init.d` boot dependencies.

## Module description

The `init.d` boot process uses a dependency based order to start and stop services. Chapter 20 of the Linux Standard Base Core Specification 3.1 defines the format of a compliant Init Script. The Init Script for a service should include the necessary settings (e.g. the runlevels) to sucessfully start and stop the service. An override mechanism is available to allow local variations without modifying the distributed scripts. This requires the creation of files in the `/etc/insserv/overrides` directory. This module provides a way to manage these files in your environment.

## Setup

### What insserv_override affects

This module create, modifies or removes files in the `/etc/insserv/overrides` directory. These files are used to determine what services should run in a given runlevel and the order in which services are started or shut down.

### Setup requirements

The `insserv_override` module requires the Puppetlabs modules `stdlib` version 4.3.x or later.

### Beginning with insserv_override

The `insserv_override` module includes a defined type of the same name that creates override files in the proper location. It also calls the `insserv` executable to activate the new configuration.

You have to declare the type for each configuration you would like to override. See the next section for examples.

## Usage

### Update the Apache service configuration to only start in runlevel 2

```puppet
insserv_override { 'apache2':
  default_start => [ '2' ],
  default_stop  => [ '0', '1', '3', '4', '5', '6' ],
}
```

### Update dependencies for Puppet to be started last and terminated first

```puppet
insserv_override { 'puppet':
  required_start => [ '$all' ],
  required_stop  => [ '$all' ],
}
```

### Remove override for MySQL service

```puppet
insserv_override { 'mysql':
  ensure => absent,
}
```

## Reference

### Defines Types

#### Public Defined Types

* `insserv_override`: The main type to create or remove an override. Undefined parameters are not included in the override file.

##### Parameters (all optional)

* `ensure`: Whether the override file should exist or not. This parameter is passed to the File resource. Default: present

* `provides`: The names of the boot facilities provided by this script. Defaults to the resource title. Can be an array when more than one facility is provided.

* `required_start`: The names of the facilities that must be available before this facility can be started. Can be a string or an array.

* `required_stop`: The names of the facilities that must still be available when this facility is stopped. Can be a string or an array.

* `should_start`: Facilities which should be available during startup of this facility. Can be a string or an array.

* `should_stop`: Facilities which should still be available during shutdown of this facility. Can be a string or an array.

* `x_start_before`: Facilities that should be started after the current facility. Can be a string or an array.

* `x_stop_after`: Facilities that should be stopped before the current facility. Can be a string or an array.

* `default_start`: The runlevels in which the current facility should be started.

* `default_stop`: The runlevels in which the current facility should be stopped.

* `x_interactive`: Whether to start this script alone during boot so the user can interact with it at the console. This is a boolean parameter. Default: false

* `short_description`: A one-line description for the service.

## Limitations

This module is only useful on `init.d` based systems. Most modern distributions (e.g. Debian-8, Ubuntu-15.04, SLES-12, RedHat-7) are using the `systemd` boot process instead of the older `init.d` based boot process.

## Development

Feel free to send pull requests.
