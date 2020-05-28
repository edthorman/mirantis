# Mirantis Launchpad Command Reference

## Initialize a cluster config file

`launchpad init`

## Initialize or upgrade a cluster

`launchpad apply`

The supported options are:

* `--config` - Path to a cluster config file (default: `cluster.yaml`)
* `--prune` - Automatically remove nodes that are not anymore part of cluster config yaml (default: `false`)


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
* `--accept-license` - Accept license

## Reset (uninstall) a cluster

`launchpad reset`

The supported options are:

* `--config` - Path to a cluster config file (default: `cluster.yaml`)
