# Mirantis Launchpad Configuration File

Mirantis Launchpad cluster configuration is described in YAML format. You can create and modify yaml files using your favorite text editor. The default name for this file is launchpad.yaml, although other file names could be used.

## Configuration File Reference

An example `launchpad.yaml` file utilizing every possible configuration option.

```yaml
apiVersion: launchpad.mirantis.com/mke/v1.3
kind: mke+msr
metadata:
  name: launchpad-mke
spec:
  hosts:
  - role: manager
    hooks:
      apply:
        before:
          - ls -al > test.txt
        after:
          - cat test.txt
    ssh:
      address: 10.0.0.1
      user: root
      port: 22
      keyPath: ~/.ssh/id_rsa
    privateInterface: eth0
    environment:
      http_proxy: http://example.com
      NO_PROXY: 10.0.0.*
    mcrConfig:
      debug: true
      log-opts:
        max-size: 10m
        max-file: "3"
  - role: worker
    winRM:
      address: 10.0.0.2
      user: Administrator
      password: abcd1234
      port: 5986
      useHTTPS: true
      insecure: false
      useNTLM: false
      caCertPath: ~/.certs/cacert.pem
      certPath: ~/.certs/cert.pem
      keyPath: ~/.certs/key.pem
  - role: msr
    imageDir: ./msr-images
    ssh:
      address: 10.0.0.3
      user: root
      port: 22
      keyPath: ~/.ssh/id_rsa
  - role: worker
    localhost:
      enabled: true
  mke:
    version: "3.3.7"
    imageRepo: "docker.io/mirantis"
    adminUsername: admin
    adminPassword: "$MKE_ADMIN_PASSWORD"
    installFlags:
    - --default-node-orchestrator=kubernetes
    licenseFilePath: ./docker-enterprise.lic
    configFile: ./mke-config.toml
    configData: |-
      [scheduling_configuration]
        default_node_orchestrator = "kubernetes"
    cloud:
      provider: azure
      configFile: ~/cloud-provider.conf
      configData: |-
        [Global]
        region=RegionOne
  msr:
    version: 2.8.5
    imageRepo: "docker.io/mirantis"
    installFlags:
    - --dtr-external-url dtr.example.com
    - --ucp-insecure-tls
    replicaIDs: sequential
  mcr:
    version: "20.10.0"
    channel: stable
    repoURL: https://repos.mirantis.com
    installURLLinux: https://get.mirantis.com/
    installURLWindows: https://get.mirantis.com/install.ps1
  cluster:
    prune: true
```

We follow Kubernetes-like versioning and grouping in launchpad configuration so you'll see familiar attributes such as `kind`.

## Environment variable substitution

When reading the configuration file, launchpad will replace any strings starting with a dollar sign with values from the local host's environment variables. Example:

```yaml
apiVersion: launchpad.mirantis.com/mke/v1.3
kind: mke
spec:
  mke:
    installFlags:
    - --admin-password="$MKE_ADMIN_PASSWORD"
```

Very simple bash-like expressions are supported:

Expression | Meaning
-- | --
${var} | Value of var (same as $var)
${var-$DEFAULT} | If var not set, evaluate expression as $DEFAULT
${var:-$DEFAULT} | If var not set or is empty, evaluate expression as $DEFAULT
${var=$DEFAULT} | If var not set, evaluate expression as $DEFAULT
${var:=$DEFAULT} | If var not set or is empty, evaluate expression as $DEFAULT
${var+$OTHER} | If var set, evaluate expression as $OTHER, otherwise as empty string
${var:+$OTHER} | If var set, evaluate expression as $OTHER, otherwise as empty string
$$var | Escape expressions. Result will be $var.

## `apiVersion`

The latest API version is `launchpad.mirantis.com/mke/v1.3`, but earlier configuration file versions should still work without changes if you do not intend to use any of the added features of the current version.

## `kind`

Currently `mke` and `mke+msr` are supported. In future releases you may have to use `mke+msr` when the configuration contains MSR elements, for now it's informational.

## `metadata`

- `name` - Name of the cluster to be created. Affects only `launchpad` internal
storage paths currently e.g. for client bundles and log files.

## `spec`

The specification for the cluster.

### `hosts`

The machines that the cluster runs on.

- `privateInterface` - Private network address for the configured network
interface (default: `eth0`)
- `role` - Role of the machine in the cluster. Possible values are:
   - `manager`
   - `worker`
   - `msr`
- `environment` - Key - value pairs in YAML mapping syntax. Values are updated to host environment (optional)
- `mcrConfig` - Mirantis Container Runtime configuration in YAML mapping syntax, will be converted to `daemon.json` (optional)
- `hooks` - [Hooks](#hooks) configuration for running commands before or after stages (optional)
- `imageDir` - Path to a directory containing `.tar`/`.tar.gz` files produced by `docker save`. The images from that directory will be uploaded and `docker load` is used to load them.

#### Host connection options

- `ssh` - [SSH](#ssh) Secure Shell (SSH) connection configuration options
- `winRM` - [WinRM](#winrm) Windows Remote Management (WinRM) connection configuration options
- `localhost` - [Localhost)(#localhost) Target is the local host where launchpad is running

##### `ssh`

SSH configuration options.

- `address` - SSH connection address
- `user` - User to log in as (default: `root`)
- `port` - Host's ssh port (default: `22`)
- `keyPath` - A local file path to an ssh private key file (default `~/.ssh/id_rsa`)

##### `winRM`

WinRM configuration options.

- `address` - WinRM connection address
- `user` - Windows account username (default: `Administrator`)
- `password` - User account password
- `port` - Host's WinRM listening port (default: `5986`)
- `useHTTPS` - Set `true` to use HTTPS protocol. When false, plain HTTP is used. (default: `false`)
- `insecure` - Set `true` to ignore SSL certificate validation errors (default: `false`)
- `useNTLM` - Set `true` to use NTLM (default: `false`)
- `caCertPath` - Path to CA Certificate file (optional)
- `certPath` - Path to Certificate file (optional)
- `keyPath` - Path to Key file (optional)

##### `localhost`

Localhost connection configuration options.

- `enabled` - Must be set to `true` to enable.

#### Hooks configuration options

Host hooks can be used to have launchpad run commands on the host before or after operation stages.

- `apply` - Hooks for the [apply](#apply) operation (optional)
- `reset` - Hooks for the [reset](#reset) operation (optional)

##### Apply

- `before`- A list of commands to run on the host before the "Preparing host" phase (optional)
- `after`- A list of commands to run on the host before the "Disconnect" phase when the apply was succesful (optional)

##### Reset

- `before`- A list of commands to run on the host before the "Uninstall" phase (optional)
- `after`- A list of commands to run on the host before the "Disconnect" phase when the reset was succesful (optional)

### `mke`

Specify options for the MKE cluster.

- `version` - Which version of MKE we should install or upgrade to (default `3.3.7`)
- `imageRepo` - Which image repository we should use for MKE installation (default `docker.io/mirantis`)
- `adminUsername` - MKE administrator username (default: `admin`)
- `adminPassword`- MKE administrator password (default: auto-generate)
- `installFlags` - Custom installation flags for MKE installation.
- `upgradeFlags`- Custom upgrade flags for an MKE upgrade. You can get a list of supported installation options for a specific MKE version by running the installer container with `docker run -t -i --rm docker/ucp:3.3.7 upgrade --help`. (optional)
- `licenseFilePath` - Optional. A path to Docker Enterprise license file.
- `configFile` - Optional. The initial full cluster [configuration file](https://docs.mirantis.com/containers/v3.1/dockeree-products/mke/mke-configure/mke-configuration-file.html).
- `configData` -  Optional. The initial full cluster [configuration file](https://docs.mirantis.com/containers/v3.1/dockeree-products/mke/mke-configure/mke-configuration-file.html) in embedded "heredocs" syntax. Heredocs allows you to define a mulitiline string while maintaining the original formatting and indenting
- `cloud` - Optional. Cloud provider configuration
- `swarmInstallFlags` - Custom flags for Swarm initialization (optional)
- `swarmUpdateCommands` - Custom commands to run after the Swarm initialization (optional)

**Note:** The MKE installer will automatically generate an administrator password unless provided and it will be displayed in clear text in the output and persisted in the logs. The automatically generated password must be configured in the `launchpad.yaml` for any subsequent runs or they will fail.

#### `cloud`

Cloud provider configuration.

- `provider` - Provider name (currently aws, azure and openstack (MKE 3.3.3+) are supported) (optional)
- `configFile` - Path to cloud provider configuration file on local machine (optional)
- `configData` - Inlined cloud provider configuration (optional)

### `msr`

Specify options for the MSR cluster.

- `version` - Which version of MSR we should install or upgrade to (default `2.8.5`)
- `imageRepo` - Which image repository we should use for MSR installation (default `docker.io/mirantis`)
- `installFlags` - Custom installation flags for MSR installation.  You can get a list of supported installation options for a specific MSR version by running the installer container with `docker run -t -i --rm mirantis/dtr:2.8.5 install --help`. (optional)

    **Note**: `launchpad` will inherit the MKE flags which are needed by MSR to perform installation, joining and removal of nodes.  There's no need to include the following install flags in the `installFlags` section of `msr`:
    - `--ucp-username` (inherited from MKE's `--admin-username` flag or `spec.mke.adminUsername`)
    - `--ucp-password` (inherited from MKE's `--admin-password` flag or `spec.mke.adminPassword`)
    - `--ucp-url` (inherited from MKE's `--san` flag or intelligently selected based on other configuration variables)

- `upgradeFlags`- Custom upgrade flags for an MSR upgrade. You can get a list of supported installation options for a specific MSR version by running the installer container with `docker run -t -i --rm docker/dtr:2.8.5 upgrade --help`. (optional)
- `replicaIDs` - Set to `sequential` to generate sequential replica id's for cluster members, for example `000000000001`, `000000000002`, etc. (default: `random`)

### `mcr`

Specify options for the Mirantis Container Runtime.

- `version` - The version of MCR you want to install or upgraded to. (default `20.10.0`)
- `channel` - Installation channel to use. One of `test` or `prod` (optional)
- `repoURL` - Repository URL to use for MCR installation. (optional)
- `installURLLinux` - Where to download the initial installer script for linux hosts. Local paths can also be used. (default: `https://get.mirantis.com/`)
- `installURLWindows` - Where to download the initial installer script for windows hosts. Also local paths can be used. (default: `https://get.mirantis.com/install.ps1`)

**Note:** In most scenarios, you should not need to specify `repoUrl` and `installURLLinux/Windows`, which are only usually used when installing from a non-standard location like a disconnected datacenter.

### `cluster`

Specify options not specific to any of the individual components.

- `prune` - Set to `true` to remove nodes that are known by the cluster but not listed in the `launchpad.yaml`.

## Related topics

* [Mirantis Launchpad command reference](command-reference.md)
