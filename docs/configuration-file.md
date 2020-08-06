# Mirantis Launchpad Configuration File

Mirantis Launchpad cluster configuration is described in a file that is in YAML format. You can create and modify these files using your favorite text editor. The default name for this file is cluster.yaml, although other file names could be used.

## Configuration File Reference

The complete `cluster.yaml` reference for UCP clusters:

```yaml
apiVersion: launchpad.mirantis.com/v1beta2
kind: UCP
metadata:
  name: launchpad-ucp
spec:
  hosts:
  - address: 10.0.0.1
    role: manager
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
        port: 5986
        useHTTPS: true
        insecure: false
        useNTLM: false
        caCertPath: ~/.certs/cacert.pem
        certPath: ~/.certs/cert.pem
        keyPath: ~/.certs/key.pem
        password: abcd1234
  - address: 10.0.0.3
    role: dtr
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
  ucp:
    version: 3.3.0-rc4
    imageRepo: "docker.io/docker"
    installFlags:
    - --admin-username=admin
    - --admin-password=orcaorcaorca
    configFile: ./ucp-config.toml
    configData: |-
      [scheduling_configuration]
        default_node_orchestrator = "kubernetes"
    cloud:
      provider: azure
      configFile: ~/cloud-provider.conf
      configData: |-
        [Global]
        region=RegionOne
  dtr:
    version: 2.8.1
    imageRepo: "docker.io/docker"
    installFlags:
    - --dtr-external-url dtr.example.com
    - --ucp-insecure-tls
    replicaConfig: sequential
  engine:
    version: 19.03.8-rc1
    channel: test
    repoURL: https://repos.mirantis.com
    installURLLinux: https://get.mirantis.com/
    installURLWindows: https://get.mirantis.com/install.ps1
```

We follow Kubernetes like versioning and grouping the launchpad configuration, hence you'll see familiar attributes such as `kind` etc.

## `apiVersion`

Currently `launchpad.mirantis.com/v1beta1` and `launchpad.mirantis.com/v1beta2` are supported. A `v1beta1` configuration will still work unchanged, but `v1beta2` features such as `environment`, `engineConfig` and `winRM` can not be used with `v1beta2`.

## `kind`

Currently only `UCP` is supported.

## `metadata`

- `name` - Name of the cluster to be created. Affects only `launchpad` internal storage paths currently e.g. for client bundles and log files.

## `spec`

The specification for the cluster.

### `hosts`

Specify the machines for the cluster.

- `address` - Address of the machine. This needs to be an address to which `launchpad` tool can connect to with SSH protocol.
- `user` - Username with sudo/admin permission to use for logging in (default: `root`)
- `environment` - Key - value pairs in YAML map (hash, dictionary) syntax. Values will be updated to host environment.
- `ssh` - SSH connection configuration options
- `winRM` - WinRM connection configuration options
- `engineConfig` - Docker Engine configuration in YAML mapping syntax, will be converted to `daemon.json`.
- `privateInterface` - Discover private network address from the configured network interface (optional)
- `role` - One of `manager` or `worker`, specifies the role of the machine in the cluster

#### `ssh`

- `user` - User to log in as (default: `root`)
- `port` - Host's ssh port (default: `22`)
- `keyPath` - A local file path to an ssh private key file (default `~/.ssh/id_rsa`)

#### `winRM`

- `port` - Host's WinRM listening port (default: `5986`)
- `useHTTPS` - Set `true` to use HTTPS protocol. When false, plain HTTP is used. (default: `false`)
- `insecure` - Set `true` to ignore SSL certificate validation errors (default: `false`)
- `useNTLM` - Set `true` to use NTLM (default: `false`)
- `caCertPath` - Path to CA Certificate file
- `certPath` - Path to Certificate file
- `keyPath` - Path to Key file
- `user` - Windows account username (default: `Administrator`)
- `password` - User account password

### `ucp`

Specify options for UCP cluster itself.

- `version` - Which version of UCP we should install or upgrade to (default `3.3.0`)
- `imageRepo` - Which image repository we should use for UCP installation (default `docker.io/docker`)
- `installFlags` - Custom installation flags for UCP installation. You can get a list of supported installation options for a specific UCP version by running the installer container with `docker run -t -i --rm docker/ucp:3.3.0 install --help`. (optional)
- `configFile` - The initial full cluster [configuration file](https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/ucp/ucp-configure/ucp-configuration-file.html#configuration-options). (optional)
- `configData` -  The initial full cluster [configuration file](https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/ucp/ucp-configure/ucp-configuration-file.html#configuration-options) in embedded "heredocs" way. (optional)
- `cloud` - Cloud provider configuration (optional)

#### `cloud`

Cloud provider configuration. 

- `provider` - Provider name (currently azure and openstack (UCP 3.4.0+) are supported)
- `configFile` - Path to cloud provider configuration file on local machine
- `configData` - Inlined cloud provider configuration

### `dtr`

Specify options for the DTR cluster itself.

- `version` - Which version of DTR we should install or upgrade to (default `2.8.1`)
- `imageRepo` - Which image repository we should use for DTR installation (default `docker.io/docker`)
- `installFlags` - Custom installation flags for DTR installation.  You can get a list of supported installation options for a specific DTR version by running the installer container with `docker run -t -i --rm docker/dtr:2.8.1 install --help`. (optional)

    **Note**: `launchpad` will inherit UCP flags which are needed by DTR to perform installation, joining and removal of nodes.  There's no need to include the following install flags in the `installFlags` section of `dtr`:
    - `--ucp-username` (inherited from UCP's `--admin-username` flag)
    - `--ucp-password` (inherited from UCP's `--admin-password` flag)
    - `--ucp-url` (inherited from UCP's `--san` flag or intelligently selected based on other configuration variables)

- `replicaConfig` - Set to `sequential` to generate sequential replica id's for cluster members, for example `000000000001`, `000000000002`, etc. (default: `random`)


 
### `engine`

 Specify options for Docker EE engine to be installed

- `version` - The version of Docker EE engine to be installed or upgraded to. (default `19.03.8`)
- `channel` - Which installation channel to use. One of `test` or `prod` (optional)
- `repoURL` - Which repository URL to use for engine installation. (optional)
- `installURLLinux` - Where to download the initial installer script for linux hosts. Also local paths can be used. (default: `https://get.mirantis.com/`)
- `installURLWindows` - Where to download the initial installer script for windows hosts. Also local paths can be used. (default: `https://get.mirantis.com/install.ps1`)

**Note:** Normally you should not need to specify anything else than the version for the engine. `repoUrl` and `installURLLinux/Windows` are only usually used when installing from non-standard location, e.g. when running in disconnected datacenters.

