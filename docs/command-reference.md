# Mirantis Launchpad command reference


## Available for all Launchpad commands

Optional arguments that can be used with any of the `launchpad` commands.

* `--disable-telemetry` - Disables sending of analytics and telemetry data
* `--accept-license` - Accept the [end user license agreement](https://github.com/Mirantis/launchpad/blob/master/LICENSE)
* `--debug` - Increase output verbosity
* `--help` - Display command help

## Initialize Launchpad

Intializes the cluster config file, usually called cluster.yaml.

`launchpad init`

## Initialize or upgrade a cluster

After you initialize the cluster config file, you can _apply_ the settings and
initialize or upgrade a cluster.

`launchpad apply`

The supported options are:

* `--config` - Path to a cluster config file, including the filename
(default: `cluster.yaml`)
* `--prune` - Remove nodes that are no longer in the cluster config yaml
(default: `false`)
* `--force` - Continue installation when prerequisite validation fails
(default: `false`)

## Download a client bundle

The client bundle contains a private and public key pair that authorizes
Launchpad to interact with
[UCP CLI](https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/ucp/user-access.html#cli-access).

`launchpad download-bundle`

The supported options are:

* `--username` - Username
* `--password` - Password
* `--config` - Path to a cluster config file, including the filename
(default: `cluster.yaml`)

## Register

Registers a user.

`launchpad register`

The supported options are:

* `--name` - Name
* `--email` - Email
* `--company` - Company

## Reset or uninstall a cluster

To reset or uninstall a UCP cluster.

`launchpad reset`

The supported options are:

* `--config` - Path to a cluster config file, including the filename (default: `cluster.yaml`)

## Related topics

* [Launchpad configuration file reference](configuration-file.md)
