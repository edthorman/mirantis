# Mirantis Launchpad Command Reference

## Common arguments

* `--disable-telemetry` - Disables sending of analytics and telemetry data
* `--accept-license` - Accept the [end user license agreement](https://github.com/Mirantis/launchpad/blob/master/LICENSE) 
* `--debug` - Increase output verbosity
* `--help` - Display command help

## Initialize a cluster config file

`launchpad init`

## Initialize or upgrade a cluster

`launchpad apply`

The supported options are:

* `--config` - Path to a cluster config file (default: `cluster.yaml`)
* `--prune` - Automatically remove nodes that are not anymore part of cluster config yaml (default: `false`)
* `--force` - Continue installation in some cases where prerequisite validation fails (default: `false`)

## Download a Client Bundle

`launchpad download-bundle`

The supported options are:

* `--username` - Username
* `--password` - Password
* `--config` - Path to a cluster config file (default: `cluster.yaml`)

## Register

`launchpad register`

The supported options are:

* `--name` - Name
* `--email` - Email
* `--company` - Company

## Reset (uninstall) a cluster

`launchpad reset`

The supported options are:

* `--config` - Path to a cluster config file (default: `cluster.yaml`)
