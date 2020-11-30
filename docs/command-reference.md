# Mirantis Launchpad command reference


## Available for all Launchpad commands

Optional arguments that can be used with any of the `launchpad` commands.

* `--disable-telemetry` - Disables sending of analytics and telemetry data
* `--accept-license` - Accept the [end user license agreement](https://github.com/Mirantis/launchpad/blob/master/LICENSE)
* `--disable-upgrade-check` - Don't check for a launchpad upgrade
* `--debug` - Increase output verbosity
* `--help` - Display command help

## Initialize Launchpad

Intializes the cluster config file, usually called launchpad.yaml.

`launchpad init`

## Initialize or upgrade a cluster

After you initialize the cluster config file, you can _apply_ the settings and
initialize or upgrade a cluster.

`launchpad apply`

The supported options are:

* `--config` - Path to a cluster config file, including the filename (default: `launchpad.yaml`, read from stdin: `-`)
(default: `launchpad.yaml`)
* `--force` - Continue installation when prerequisite validation fails
(default: `false`)
* `--disable-redact` - Do not hide sensitive information in the output
(default: `false`)
* `--confirm` - Request confirmation for every command to be run on the remote hosts
(default: `false`)

## Download client configuration

The MKE client bundle contains a private and public key pair that authorizes
Launchpad to interact with the [MKE CLI](https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/ucp/user-access.html#cli-access).

`launchpad client-config`

The supported options are:

* `--config` - Path to a cluster config file, including the filename (default: `launchpad.yaml`, read from stdin: `-`)
(default: `launchpad.yaml`)

**Note:** The configuration must include the MKE credentials, example:

```yaml
apiVersion: launchpad.mirantis.com/mke/v1.1
kind: mke
spec:
  mke:
    adminUsername: admin
    adminPassword: password
```

## Reset or uninstall a cluster

To reset or uninstall an MKE cluster.

`launchpad reset`

The supported options are:

* `--config` - Path to a cluster config file, including the filename (default: `launchpad.yaml`, read from stdin: `-`)
* `--force` - Required when running non-interactively (default: `false`)
* `--disable-redact` - Do not hide sensitive information in the output
(default: `false`)
* `--confirm` - Request confirmation for every command to be run on the remote hosts
(default: `false`)

## Execute a command or run a remote terminal on a host

You can use launchpad to run commands or an interactive terminal on the hosts in the configuration.

`launchpad exec`

The supported options are:

* `--config` - Path to a cluster config file, including the filename (default: `launchpad.yaml`, read from stdin: `-`)
* `--target value`  - Target host (example: address[:port])
* `--interactive` - Run interactive (default: false)
* `--first` - Use the first target found in configuration (default: false)
* `--role value` - Use the first target having this role in configuration
* `[command]` - The command to run. When blank, will run the default shell.

## Show cluster status

`launchpad describe`

The supported options are:

* `--config` - Path to a cluster config file, including the filename (default: `launchpad.yaml`, read from stdin: `-`)
* `--disable-redact` - Do not hide sensitive information in the output
(default: `false`)
* `--confirm` - Request confirmation for every command to be run on the remote hosts
(default: `false`)
* `[report name]` - Currently supported reports: `config`, `hosts`, `mke`, `msr`

## Register

Registers a user.

`launchpad register`

The supported options are:

* `--name` - Name
* `--email` - Email
* `--company` - Company


## Generate shell auto-completions

`launchpad completion`

The supported options are:

* `--shell` - Generate completions for the specified shell. Supported shells are bash, zsh and fish. (default: `$SHELL`)

### Installing the completion scripts:

These examples will place the completion script into the most common directory for most systems, on some systems the paths may be different. Usually this needs a restart of the shell session, the second command can be used to load the completions immediately to the current shell session without restarting.

Bash:
```
$ launchpad completion -s bash > /etc/bash_completion.d/launchpad
$ source /etc/bash_completion.d/launchpad
```

Zsh:
```
$ launchpad completion -s zsh > /usr/local/share/zsh/site-functions/_launchpad
$ source /usr/local/share/zsh/site-functions/_launchpad
```

Fish:
```
$ launchpad completion -s fish > ~/.config/fish/completions/launchpad.fish
$ source ~/.config/fish/completions/launchpad.fish
```

## Related topics

* [Launchpad configuration file reference](configuration-file.md)
