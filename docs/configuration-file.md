# Mirantis Launchpad Configuration File

Mirantis Launchpad cluster configuration is described in YAML format. You can create and modify yaml files using your favorite text editor. The default name for this file is launchpad.yaml, although other file names could be used.

## Configuration File Reference

The complete `launchpad.yaml` file looks something like this, but with values determined by your specific configuration.

```yaml
apiVersion: launchpad.mirantis.com/mke/v1.1
kind: mke+msr
metadata:
  name: launchpad-mke
spec:
  hosts:
  - address: 10.0.0.1
    role: manager
    hooks:
      apply:
        before:
          - ls -al > test.txt
        after:
          - cat test.txt
          - rm test.txt
    ssh:
      user: root
      port: 22
      keyPath: ~/.ssh/id_rsa
    privateInterface: eth0
    environment:
      http_proxy: http://example.com
      NO_PROXY: 10.0.0.*
    engineConfig:
      debug: true
      log-opts:
        max-size: 10m
        max-file: "3"
  - address: 10.0.0.2
    role: worker
    winRM:
      user: Administrator
      password: abcd1234
      port: 5986
      useHTTPS: true
      insecure: false
      useNTLM: false
      caCertPath: ~/.certs/cacert.pem
      certPath: ~/.certs/cert.pem
      keyPath: ~/.certs/key.pem
  - address: 10.0.0.3
    role: msr
    imageDir: ./dtr-images
    ssh:
      user: root
      port: 22
      keyPath: ~/.ssh/id_rsa
  - address: 127.0.0.1
    role: worker
    localhost: true
  mke:
    version: "3.3.3"
    imageRepo: "docker.io/docker"
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
    version: 2.8.1
    imageRepo: "docker.io/docker"
    installFlags:
    - --dtr-external-url dtr.example.com
    - --ucp-insecure-tls
    replicaIDs: sequential
  engine:
    version: "19.03.8"
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
apiVersion: launchpad.mirantis.com/mke/v1.1
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

The latest API version is `launchpad.mirantis.com/mke/v1.1`, but earlier configuration file versions should still work without changes if you do not intend to use any of the added features of the current version.

## `kind`

Currently `mke` and `mke+msr` are supported. In future releases you may have to use `mke+msr` when the configuration contains MSR elements, for now it's informational.

## `metadata`

- `name` - Name of the cluster to be created. Affects only `launchpad` internal
storage paths currently e.g. for client bundles and log files.

## `spec`

The specification for the cluster.

### `hosts`

The machines that the cluster runs on.

- `address` - Address of the server that `launchpad` can connect to using the selected [connection](#host-connection-options) method
- `privateInterface` - Private network address for the configured network
interface (default: `eth0`)
- `role` - Role of the machine in the cluster. Possible values are:
   - `manager`
   - `worker`
   - `msr`
- `environment` - Key - value pairs in YAML mapping syntax. Values are updated to host environment (optional)
- `engineConfig` - Docker Engine configuration in YAML mapping syntax, will be converted to `daemon.json` (optional)
- `hooks` - [Hooks](#hooks) configuration for running commands before or after stages (optional)
- `imageDir` - Path to a directory containing `.tar`/`.tar.gz` files produced by `docker save`. The images from that directory will be uploaded and `docker load` is used to load them.

#### Host connection options

- `ssh` - [SSH](#ssh) Secure Shell (SSH) connection configuration options
- `winRM` - [WinRM](#winrm) Windows Remote Management (WinRM) connection configuration options
- `localhost` - Target is the local host where launchpad is running (boolean, default: false)

##### `ssh`

SSH configuration options.

- `user` - User to log in as (default: `root`)
- `port` - Host's ssh port (default: `22`)
- `keyPath` - A local file path to an ssh private key file (default `~/.ssh/id_rsa`)

##### `winRM`

WinRM configuration options.

- `user` - Windows account username (default: `Administrator`)
- `password` - User account password
- `port` - Host's WinRM listening port (default: `5986`)
- `useHTTPS` - Set `true` to use HTTPS protocol. When false, plain HTTP is used. (default: `false`)
- `insecure` - Set `true` to ignore SSL certificate validation errors (default: `false`)
- `useNTLM` - Set `true` to use NTLM (default: `false`)
- `caCertPath` - Path to CA Certificate file (optional)
- `certPath` - Path to Certificate file (optional)
- `keyPath` - Path to Key file (optional)

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

Specify options for the MKE cluster itself.

- `version` - Which version of MKE we should install or upgrade to (default `3.3.3`)
- `imageRepo` - Which image repository we should use for MKE installation (default `docker.io/docker`)
- `adminUsername` - MKE administrator username (default: `admin`)
- `adminPassword`- MKE administrator password (default: auto-generate)
- `installFlags` - Custom installation flags for MKE installation. You can get a list of supported installation options for a specific MKE version by running the installer container with `docker run -t -i --rm docker/ucp:3.3.0 install --help`. (optional)
- `licenseFilePath` - Optional. A path to Docker Enterprise license file.
- `configFile` - Optional. The initial full cluster [configuration file](https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/ucp/ucp-configure/ucp-configuration-file.html).
- `configData` -  Optional. The initial full cluster [configuration file](https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/ucp/ucp-configure/ucp-configuration-file.html) in embedded "heredocs" way. Heredocs allows you to define a mulitiline string while maintaining the original formatting and indenting
- `cloud` - Optional. Cloud provider configuration

**Note:** The MKE installer will automatically generate an administrator password unless provided and it will be displayed in clear text in the output and persisted in the logs. The automatically generated password must be configured in the `launchpad.yaml` for any subsequent runs or they will fail.

#### `cloud`

Cloud provider configuration.

- `provider` - Provider name (currently aws, azure and openstack (MKE 3.3.3+) are supported) (optional)
- `configFile` - Path to cloud provider configuration file on local machine (optional)
- `configData` - Inlined cloud provider configuration (optional)

### `msr`

Specify options for the MSR cluster.

- `version` - Which version of MSR we should install or upgrade to (default `2.8.3`)
- `imageRepo` - Which image repository we should use for MSR installation (default `docker.io/mirantis`)
- `installFlags` - Custom installation flags for MSR installation.  You can get a list of supported installation options for a specific MSR version by running the installer container with `docker run -t -i --rm mirantis/dtr:2.8.3 install --help`. (optional)

    **Note**: `launchpad` will inherit the MKE flags which are needed by MSR to perform installation, joining and removal of nodes.  There's no need to include the following install flags in the `installFlags` section of `msr`:
    - `--ucp-username` (inherited from MKE's `--admin-username` flag or `spec.mke.adminUsername`)
    - `--ucp-password` (inherited from MKE's `--admin-password` flag or `spec.mke.adminPassword`)
    - `--ucp-url` (inherited from MKE's `--san` flag or intelligently selected based on other configuration variables)

- `replicaIDs` - Set to `sequential` to generate sequential replica id's for cluster members, for example `000000000001`, `000000000002`, etc. (default: `random`)

### `engine`

 Specify options for Docker Engine - Enterprise to be installed

- `version` - The version of engine that you want to install or upgraded to. (default `19.03.12`)
- `channel` - Installation channel to use. One of `test` or `prod` (optional)
- `repoURL` - Repository URL to use for engine installation. (optional)
- `installURLLinux` - Where to download the initial installer script for linux hosts. Local paths can also be used. (default: `https://get.mirantis.com/`)
- `installURLWindows` - Where to download the initial installer script for windows hosts. Also local paths can be used. (default: `https://get.mirantis.com/install.ps1`)

    **Note:** In most scenarios, you should not need to specify `repoUrl` and `installURLLinux/Windows`, which are only usually used when installing from a non-standard location like a disconnected datacenter.

### `cluster`

 Specify options not specific to any of the individual components.

- `prune` - Set to `true` to remove nodes that are known by the cluster but not listed in the `launchpad.yaml`.

## Related topics

* [Mirantis Launchpad command reference](command-reference.md)
