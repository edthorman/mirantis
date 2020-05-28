# Mirantis Launchpad Configuration File

Mirantis Launchpad cluster configuration is described in a file that is in YAML format. You can create and modify these files using your favorite text editor. The default name for this file is cluster.yaml, although other file names could be used.

## Configuration File Reference

The complete `cluster.yaml` reference for UCP clusters:

```yaml
apiVersion: launchpad.mirantis.com/v1beta1
kind: UCP
metadata:
  name: launchpad-ucp
spec:
  hosts:
  - address: 1.2.1.2
    user: root
    sshPort: 22
    sshKeyPath: ~/.ssh/id_rsa
    privateInterface: eth0
    role: manager
  # - address: 1.3.1.3
  #   user: root
  #   sshKeyPath: ~/.ssh/id_rsa
  #   privateInterface: ens5
  #   role: worker
  # - address: 1.4.1.4
  #   user: docker
  #   sshKeyPath: ~/.ssh/id_rsa
  #   privateInterface: "Ethernet 3"
  #   role: worker
  # ucp:
  #   version: 3.3.0-rc4
  #   imageRepo: "docker.io/docker"
  #   installFlags:
  #   - --admin-username=admin
  #   - --admin-password=orcaorcaorca
  #   configFile: ./ucp-config.toml
  #   configData: |-
  #     [scheduling_configuration]
  #       default_node_orchestrator = "kubernetes"
  # engine:
  #   version: 19.03.8-rc1
  #   channel: test
  #   repoURL: https://repos.mirantis.com
  #   installURL: https://get.mirantis.com/
```

We follow Kubernetes like versioning and grouping the launchpad configuration, hence you'll see familiar attributes such as `kind` etc.

## `apiVersion`

Currently only `launchpad.mirantis.com/v1beta1` is supported.

## `kind`

Currently only `UCP` is supported.

## `metadata`

- `name` - Name of the cluster to be created. Affects only `launchpad` internal storage paths currently e.g. for client bundles.

## `spec`

The specification for the cluster.

### `hosts`

Specify the machines for the cluster.

- `address` - Address of the machine. This needs to be an address to which `launchpad` tool can connect to with SSH protocol.
- `user` - Username with sudo/admin permission to use for logging in (default: `root`)
- `sshPort` - Host's ssh port (default: `22`)
- `sshKeyPath` - A local file path to an ssh private key file (default `~/.ssh/id_rsa`)
- `privateInterface` - Discover private network address from the configured network interface (optional)
- `role` - One of `manager` or `worker`, specifies the role of the machine in the cluster

### `ucp`

Specify options for UCP cluster itself.

- `version` - Which version of UCP we should install or upgrade to (default `3.3.0`)
- `imageRepo` - Which image repository we should use for UCP installation (default `docker.io/docker`)
- `installFlags` - Custom installation flags for UCP installation. You can get a list of supported installation options for a specific UCP version by running the installer container with `docker run -t -i --rm docker/ucp:3.3.0 install --help`. (optional)
- `configFile` - The initial full cluster [configuration file](https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/ucp/ucp-configure/ucp-configuration-file.html#configuration-options). (optional)
- `configData` -  The initial full cluster [configuration file](https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/ucp/ucp-configure/ucp-configuration-file.html#configuration-options) in embedded "heredocs" way. (optional)

### `engine`

 Specify options for Docker EE engine to be installed

- `version` - The version of Docker EE engine to be installed or upgraded to. (default `19.03.8`)
- `channel` - Which installation channel to use. One of `test` or `prod` (optional)
- `repoURL` - Which repository URL to use for engine installation. (optional)
- `installURL` - Where to download the initial installer script. (optional)

**Note:** Normally you should not need to specify anything else than the version for the engine. `repoUrl` and `installURL` are only usually used when installing from non-standard location, e.g. when running in disconnected datacenters.

