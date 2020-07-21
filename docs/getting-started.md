# Getting Started With Mirantis Launchpad

Mirantis Launchpad is a command-line deployment/lifecycle-management tool that runs on virtually any Linux, Mac, or Windows machine. It can deploy, modify, and update Docker Enterprise on two or more hosts that meet minimum [system requirements](system-requirements.md).

Get started with Launchpad by following these steps:

1. [Plan your deployment machine](#configure-a-deployment-machine)
1. [Plan and configure your hosts](#plan-and-configure-your-hosts)
1. [Host configuration checklist](#host-configuration-checklist)
1. [Networking considerations](#networking-considerations)
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

This machine can reside in different contexts and connect with hosts several different ways, depending on the infrastructure and services at your disposal.  

Your deployer machine must be able to communicate with your hosts on their IP addresses, using several ports. Depending on your infrastructure and security requirements, this can be relatively simple to achieve for evaluation clusters. See [Networking Considerations](#networking-considerations), below.

### Plan and configure your hosts

A Docker Enterprise cluster comprises at least one Manager node and one or more Worker nodes. To begin, we recommend deploying a small evaluation cluster, with one Manager and at least one worker node. This will give you an opportunity to familiarize yourself quickly with Launchpad, with procedures for provisioning nodes, and with Docker Enterprise features (and, if you're deploying on a public cloud, minimizing costs).

Ultimately, Launchpad can deploy Docker Enterprise Manager and Worker nodes in any combination, creating many different cluster configurations. For example:

* _Small evaluation clusters_, with one Manager and one or more Worker nodes
* _Diverse clusters_, with Linux and Windows Workers
* _High-availability clusters_, with two, three, or more Manager nodes
* _Clusters that Launchpad can auto-update, non-disruptively_, with multiple Managers (allowing one-by-one update of the control plane without loss of cluster cohesion) and sufficient Worker nodes of each type to let workloads be drained to new homes as each node is updated

Your hosts must be able to communicate with one another (and potentially, with users in the outside world) on their IP addresses, using many ports. Depending on your infrastructure and security requirements, this can be relatively simple to achieve for evaluation clusters. See [Networking Considerations](#networking-considerations), below.

### Host configuration checklist

Hosts must be provisioned with:

* _Sufficient vCPU, RAM, and SSD storage_ &mdash; See [system requirements](system-requirements.md) for details. For a small evaluation cluster, Manager and Workers can be provisioned with 2 vCPUs, 8GB RAM, with a 20GB SSD. On AWS EC2, for example, these specifications are met by a t3.large instance type, with SSD storage expanded to 20GB from the default 10GB. Note that, for long-term evaluation, you should provision hosts with a minimum of 64GB mass storage so that log rotation can occur, preventing running out of disk space. [WE NEED A BETTER ANSWER HERE]
* _A supported operating system_ &mdash; Docker Enterprise Manager nodes run on a supported Linux (see [system requirements](system-requirements.md)). Worker nodes may, alternatively, run on Windows Server 2019. Note that if you intend to deploy on desktop virtualization (e.g., VirtualBox), you will need to download a supported Linux server OS as an ISO file, mount it to boot from a virtual DVD drive, and install the operating system onto the VM SSD at first launch.

Hosts must be configured to allow:

* _Access via SSH (or WinRC for Windows hosts):_
  - Public and private cloud Linux images are usually configured to enable SSH access by default.
  - Public and private cloud Windows Server images are normally configured for WinRC by default, which Launchpad supports.
  - If installing Linux on a desktop (e.g., VirtualBox) VM, you will need to install and enable the SSH server (e.g., OpenSSH) as part of initial OS installation, or access the running VM via the built-in remote terminal and install, configure, and enable OpenSSH manually, later. Google 'install ssh server &lt;your chosen Linux&gt;' for OS-specific tutorials and instructions.
  - Alternatively, Launchpad also supports SSH connections to Windows Server hosts. Enabling SSH on Windows Server will typically require post-launch configuration, and can be scripted for enablement at VM launch. See [system requirements](system-requirements.md) or [this blog](https://www.mirantis.com/blog/today-i-learned-how-to-enable-ssh-with-keypair-login-on-windows-server-2019/).


* _For hosts accessed via SSH: remote login using private key:_ &mdash; Launchpad, like most deployment tools, uses encryption keys rather than passwords to authenticate to hosts. You will need to create or use an existing keypair, copy the public key to an appropriate location on each host, configure SSH on hosts to permit keywise authentication (then restart the sshd server), and store the keypair (or just the private key) in an appropriate location on your deployer machine, with appropriate permissions. Google 'enable SSH with keys &lt;your chosen Linux&gt;' for OS-specific tutorials and instructions on creating and using SSH keypairs.
  - Keywise login is the default for Linux instances on most public and private cloud platforms. Typically, you can use the platform to create an SSH keypair (or upload a private key created elsewhere, e.g., on your deployer machine), and assign this key to VMs at launch.
  - For Linux hosts on desktop virtualization, assuming you're installing a new OS on each VM, you'll need to configure keywise SSH access after installing OpenSSH. This entails creating a private key, copying it to each host, then reconfiguring SSH on each host to use private keys instead of passwords before restarting the sshd service.
  - For Windows hosts, access via SSH and keys must be configured manually after first boot, or can be automated. See [system requirements](system-requirements.md) or [this blog](https://www.mirantis.com/blog/today-i-learned-how-to-enable-ssh-with-keypair-login-on-windows-server-2019/).


* _For Linux hosts: passwordless sudo_ &mdash; Most Linux operating systems now default to enabling login by a privileged user with sudo permissions, rather than by 'root.' This is safer than permitting direct login by root (which is also prevented by the default configuration of most SSH servers). Launchpad requires that the user be allowed to issue 'sudo' commands without being prompted to enter a password.
  - This is the default for Linux instances on most public and private cloud platforms. The username you create at VM launch will have passwordless sudo privileges.
  - If installing Linux on a desktop (e.g., VirtualBox) VM, you will typically need to configure passwordless sudo after first boot of a newly-installed OS. Google 'configure passwordless sudo &lt;your chosen Linux&gt;' for tutorials and instructions.
  - On Windows hosts, the Administrator account is given all privileges by default, and Launchpad can escalate permissions at need without a password.

* _Configure Docker logging to enable auto-rotation and manage retention_ * &mdash; Additionally, we recommend configuring evaluation hosts, especially those with smaller SSDs/HDDs, to enable basic Docker log rotation and managing old-file retention, thus avoiding filling up cluster storage with retained logs.

This can be done by ssh'ing to each host, and then:

```
$ sudo su -
```

... to become root, then creating the directory /etc/docker:

```
$ mkdir /etc/docker
```

... and, within that directory, using vi or another editor to create the file daemon.json, as shown:

```
// daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```
It's easiest to create this file before using Launchpad to install Docker Enterprise.

### Networking considerations

Most first-time Launchpad users will likely install Launchpad on a local laptop or VM, and wish to deploy Docker Enterprise onto VMs running on a public or private cloud that supports 'security groups' for IP access control. This makes it fairly simple to configure networking in a way that provides adequate security and convenient access to the cluster for evaluation and experimentation.

The simplest way to configure networking for a small, temporary evaluation cluster is to:

1. Create a new virtual subnet (or VPC and subnet) for hosts.
1. Create a new security group called 'de_hosts' (or another name of your choice) that permits inbound IPv4 traffic on all ports, either from a) the security group de_hosts, or b) the new virtual subnet only.
1. Create a second new security group (e.g., 'admit_me') that permits inbound IPv4 traffic from your deployer machine's public IP address only (you can use the website [http://whatismyip.com](http://whatismyip.com)) to determine your public IP.
1. When launching hosts, attach them to the newly-created subnet, and apply both new security groups
1. Once you know the (public, or VPN-accessible private) IPv4 addresses of your nodes, if you aren't using local DNS, it makes sense to assign names to your hosts (e.g., manager, worker1, worker2 ... etc.) and insert IP addresses and names in your hostfile, letting you (and Launchpad) refer to hosts by hostname instead of IP address.

Once hosts are booted, you should be able to SSH into them from your deployer machine with your private key, e.g.:

```
ssh -i /my/private/keyfile username@mynode
```
... and determine if they can access the internet, perhaps by pinging a Google nameserver:

```
ping 8.8.8.8
```

Once you can do this, you should be able to proceed with installing Launchpad and configuring a Docker Enterprise deployment. Once completed, you should be able to use your deployer machine to access the Docker Enterprise Universal Control Plane webUI, run kubectl (after authenticating to your cluster) and potentially other utilities (e.g., Postman, curl, etc.).

#### Using a VPN

A more-secure way to manage networking is to connect your deployer machine to your VPC/subnet using a VPN, and modify the de_hosts security group to accept traffic on all ports from this source. Most public clouds have a VPN service that can be used to set this up fairly simply.

#### More deliberate network security

If you intend to deploy a cluster for longer-term evaluation, it makes sense to secure it more deliberately. In this case, a certain range of ports will need to be opened on hosts. Please see [System Requirements: Ports Used](./docs/system-requirements.md#ports-used) for links to documentation.

#### Using DNS

Launchpad can deploy certificate bundles obtained from a certificate provider to authenticate your cluster. These can be used in combination with DNS to let you reach your cluster securely on a fully-qualified domain name (FQDN). See DOCUMENTATION LINK for more information.

## Set up Mirantis Launchpad CLI tool

UCP clusters may be deployed, managed and maintained with the Mirantis Launchpad ("**launchpad**") CLI tool. This tool is updated regularly, so make sure you are always using the latest version.

> NOTE: `launchpad` has built-in telemetry for tracking the usage of the tool. The telemetry data is used to improve the product and overall user experience. No sensitive data about the clusters is included in the telemetry payload.

Download and install the latest version of `launchpad` for the OS you are using below:

* [Download Launchpad](https://github.com/Mirantis/launchpad/releases/latest)
* Rename the downloaded binary as `launchpad` and move it to some dir in PATH and give it an execute permission.
* With OSX you have to also allow Launchpad to be executed in Security and Privacy settings.

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
```

## Create the cluster configuration file

The cluster is configured using [a yaml file](configuration-file.md). In this example we setup simple 1+1 UCP Kubernetes cluster, one node acts as the UCP control plane and one as pure worker node.

Open up your favourite editor, and type something similar as in the example below. Once done, save the file as `cluster.yaml`. Naturally you need to adjust the example below to match your infrastructure details. This model should work to deploy hosts on most public clouds.

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

If you're deploying on VirtualBox or other desktop virtualization solution and are using ‘bridged’ networking, you’ll need to make a few minor adjustments to your cluster.yaml (see below) — deliberately setting a –pod-cidr to ensure that pod IP addresses don’t overlap with node IP addresses (the latter are in the 192.168.x.x private IP network range on such a setup), and supplying appropriate labels for the target nodes’ private IP network cards using the privateInterface parameter (this typically defaults to ‘enp0s3’ on Ubuntu 18.04 &mdash; other Linux distributions use similar nomenclature).

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

The `launchpad` tool connects to the infrastructure you've specified in the `cluster.yaml` with SSH or WinRM connections and configures everything needed on the hosts. Within few minutes you should have your cluster up-and-running.

## Interact with your cluster

At the end of the installation procedure, launchpad will show you the details you can use to connect to your cluster. You will see something like this:
```
INFO[0021] ==> Running phase: UCP cluster info
INFO[0021] Cluster is now configured. You can access your cluster admin UI at: https://test-ucp-cluster-master-lb-895b79a08e57c67b.elb.eu-north-1.amazonaws.com
INFO[0021] You can also download the admin client bundle with the following command: launchpad download-bundle --username <username> --password <password>
```

By default, the admin username is `admin`. If you did not supply the password with `installFlags` option like `--admin-password=supersecret`, the generated admin password is outputted in the install flow:
```
INFO[0083] 127.0.0.1:  time="2020-05-26T05:25:12Z" level=info msg="Generated random admin password: wJm-TzIzQrRNx7d1fWMdcscu_1pN5Xs0"
```
