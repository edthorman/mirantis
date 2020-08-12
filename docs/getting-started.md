# Getting Started With Mirantis Launchpad CLI Tool

Mirantis Launchpad CLI Tool is a command-line deployment/lifecycle-management tool that runs on virtually any Linux, Mac, or Windows machine. It can deploy, modify, and update Docker Enterprise on two or more hosts that meet minimum [system requirements](system-requirements.md).

Get started with Launchpad by following these steps:

1. [Plan your deployment machine](#configure-a-deployment-machine)
1. [Plan and configure your hosts](#plan-and-configure-your-hosts)
1. [Follow the host configuration checklist](#host-configuration-checklist)
1. [Ensure networking considerations have been satisifed](#networking-considerations)
1. [Set up Mirantis Launchpad CLI tool](#set-up-mirantis-launchpad-cli-tool)
1. [Create the cluster configuration file](#create-the-cluster-configuration-file)
1. [Bootstrap your cluster](#bootstrap-your-cluster)
1. [Interact with your cluster](#interact-with-your-cluster)

### Configure a deployment machine

To fully evaluate Docker Enterprise, we recommend installing Launchpad on a Linux, Mac, or Windows laptop or VM that can also host:

* A graphic desktop and browser, for accessing:
  * The Docker Enterprise Universal Control Plane webUI
  * [Lens](https://k8slens.dev/), an open source, stand-alone GUI application from Mirantis (available for Linux, Mac, and Windows) for multi-cluster management and operations
  * Metrics, observability, visualization and other tools
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/), the Kubernetes command-line client
* curl, [Postman](https://www.postman.com/) and/or [client libraries](https://kubernetes.io/docs/reference/using-api/client-libraries/) for accessing the Kubernetes REST API
* [Docker](https://docs.docker.com/get-docker/) and related tools, for using the 'docker swarm' CLI, and for containerizing workloads and accessing local and remote registries

This machine can reside in different contexts from the hosts and connect with them several different ways, depending on the infrastructure and services at your disposal.

Your deployer machine must be able to communicate with your hosts on their IP addresses, using several ports. Depending on your infrastructure and security requirements, this can be relatively simple to achieve for evaluation clusters. See [Networking Considerations](networking-considerations.md) for more.

### Plan and configure your hosts

A Docker Enterprise cluster comprises at least one Manager node and one or more Worker nodes. To begin, we recommend deploying a small evaluation cluster, with one Manager and at least one worker node. This will give you an opportunity to familiarize yourself quickly with Launchpad, with procedures for provisioning nodes, and with Docker Enterprise features (and, if you're deploying on a public cloud, minimizing costs).

Ultimately, Launchpad can deploy Docker Enterprise Manager and Worker nodes in any combination, creating many different cluster configurations. For example:

* _Small evaluation clusters_, with one Manager and one or more Worker nodes
* _Diverse clusters_, with Linux and Windows Workers
* _High-availability clusters_, with two, three, or more Manager nodes
* _Clusters that Launchpad can auto-update, non-disruptively_, with multiple Managers (allowing one-by-one update of the control plane without loss of cluster cohesion) and sufficient Worker nodes of each type to let workloads be drained to new homes as each node is updated

Your hosts must be able to communicate with one another (and potentially, with users in the outside world) on their IP addresses, using many ports. Depending on your infrastructure and security requirements, this can be relatively simple to achieve for evaluation clusters. See [Networking Considerations](networking-considerations.md).

### Host configuration checklist

Hosts must be provisioned with:

* _Sufficient vCPU, RAM, and SSD storage_ &mdash; See [system requirements](system-requirements.md) and [host configuration](host-configuration.md) for details. For a small evaluation cluster, Manager and Workers can be provisioned with 2 vCPUs, 8GB RAM, with a 20GB SSD. On AWS EC2, for example, these specifications are met by a t3.large instance type, with SSD storage expanded to 20GB from the default 10GB.
* _A supported operating system_ &mdash; Docker Enterprise Manager nodes run on a supported Linux (see [system requirements](system-requirements.md)). Worker nodes may, alternatively, run on Windows Server 2019.

Hosts must be configured to allow:

* _Access via SSH (or WinRM for Windows hosts):_ &mdash; See [system requirements](system-requirements.md) and [host configuration](host-configuration.md) for more info.

* _For hosts accessed via SSH: remote login using private key:_ &mdash; See [system requirements](system-requirements.md) and [host configuration](host-configuration.md) for more info.

* _For Linux hosts: passwordless sudo_ &mdash; See [system requirements](system-requirements.md) and [host configuration](host-configuration.md) for more info.

Hosts launched on most public clouds (e.g., AWS, Azure) typically provide this access configuration as default.

* _(Recommended) Configure Docker logging to enable auto-rotation and manage log retention_ * &mdash; See [system requirements](system-requirements.md) and [host configuration](host-configuration.md) for more info.

## Networking considerations

Most first-time Launchpad users will likely install Launchpad on a local laptop or VM, and wish to deploy Docker Enterprise onto VMs running on a public or private cloud that supports 'security groups' for IP access control. This makes it fairly simple to configure networking in a way that provides adequate security and convenient access to the cluster for evaluation and experimentation. See [Networking Considerations](networking-considerations.md) for a simple recommended setup.

## Set up Mirantis Launchpad CLI tool

UCP clusters may be deployed, managed and maintained with the Mirantis Launchpad ("**launchpad**") CLI tool. This tool is updated regularly, so make sure you are always using the latest version.

> NOTE: `launchpad` has built-in telemetry for tracking the usage of the tool. The telemetry data is used to improve the product and overall user experience. No sensitive data about the clusters is included in the telemetry payload.

Download and install the latest version of `launchpad` for the OS you are using below:

* [Download Launchpad](https://github.com/Mirantis/launchpad/releases/latest)
* Rename the downloaded binary as `launchpad` and move it to some dir in PATH and give it an execute permission.
* With macOS you may also have to also allow Launchpad to be executed in the Security and Privacy settings.

Once installed, verify the installation by checking the installed tool version:

```
$ launchpad version
version: 1.0.0
```

To finalize the installation, you'll need to complete the registration. The information provided via registration is used to assign evaluation licenses and for providing assistance for the usage of the product. Use `launchpad register` command to complete the registration:

```
$ launchpad register
name: Luke Skywalker
company: Jedi Corp
email: luke@jedicorp.com
I agree to Mirantis Launchpad Software Evaluation License Agreement https://github.com/Mirantis/launchpad/blob/master/LICENSE [Y/n]: Yes
INFO[0022] Registration completed!
```

## Create the cluster configuration file

The cluster is configured using [a yaml file](configuration-file.md). In this example we setup simple 1+1 UCP Kubernetes cluster, where one node acts as the UCP control plane and one as pure worker node.

Open up your favourite editor, and type something similar to the example below. Once done, save the file as `cluster.yaml`. Naturally you need to adjust the example below to match your infrastructure details. This model should work to deploy hosts on most public clouds.

```yaml
apiVersion: launchpad.mirantis.com/v1beta2
kind: UCP
metadata:
  name: ucp-kube
spec:
  ucp:
    installFlags:
    - --admin-username=admin
    - --admin-password=passw0rd!
    - --default-node-orchestrator=kubernetes
  hosts:
  - address: 172.16.33.100
    role: manager
    ssh:
      keyPath: ~/.ssh/my_key
  - address: 172.16.33.101
    role: worker
    ssh:
      keyPath: ~/.ssh/my_key
```

If you're deploying on VirtualBox or other desktop virtualization solution and are using ‘bridged’ networking, you’ll need to make a few minor adjustments to your cluster.yaml (see below) — deliberately setting a –pod-cidr to ensure that pod IP addresses don’t overlap with node IP addresses (the latter are in the 192.168.x.x private IP network range on such a setup), and supplying appropriate labels for the target nodes’ private IP network cards using the privateInterface parameter (this typically defaults to ‘enp0s3’ on Ubuntu 18.04 &mdash; other Linux distributions use similar nomenclature). You may also need to set the username to use for logging into the host.

```yaml
apiVersion: launchpad.mirantis.com/v1beta2
kind: UCP
metadata:
  name: my-ucp
spec:
  ucp:
    installFlags:
      - --admin-username=admin
      - --admin-password=passw0rd!
      - --default-node-orchestrator=kubernetes
      - --pod-cidr 10.0.0.0/16
  hosts:
  - address: 192.168.110.100
    role: manager
    ssh:
      keyPath: ~/.ssh/id_rsa
      user: theuser
    privateInterface: enp0s3
  - address: 192.168.110.101
    role: worker
    ssh:
      keyPath: ~/.ssh/id_rsa
      user: theuser
    privateInterface: enp0s3
```
For more complex setups, there's a huge amount of [configuration options](configuration-file.md) available.

## Bootstrap your cluster

Once the cluster configuration file is ready, we can fire up the cluster. In the same directory where you created the `cluster.yaml` file, run:

```
$ launchpad apply
```

The `launchpad` tool uses with SSH or WinRM to connect to the infrastructure you've specified in the `cluster.yaml` and configures everything needed on the hosts. Within few minutes you should have your cluster up and running.

## Interact with your cluster

At the end of the installation procedure, launchpad will show you the details you can use to connect to your cluster. You will see something like this:
```
INFO[0021] ==> Running phase: UCP cluster info
INFO[0021] Cluster is now configured. You can access your cluster admin UI at: https://test-ucp-cluster-master-lb-895b79a08e57c67b.elb.eu-north-1.amazonaws.com
INFO[0021] You can also download the admin client bundle with the following command: launchpad download-bundle --username <username> --password <password>
```

By default, the admin username is `admin`. If you did not supply the password in with `cluster.yaml` or via the `installFlags` option like `--admin-password=supersecret`, the generated admin password will be displayed in the install flow:
```
INFO[0083] 127.0.0.1:  time="2020-05-26T05:25:12Z" level=info msg="Generated random admin password: wJm-TzIzQrRNx7d1fWMdcscu_1pN5Xs0"
```
