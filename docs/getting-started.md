# Get Started With Mirantis Launchpad CLI Tool

Mirantis Launchpad CLI Tool (Launchpad) is a command-line deployment and lifecycle-management tool that runs on virtually any Linux, Mac, or Windows machine. You can use it to install, deploy, modify, and update Docker Enterprise.

Before following these steps, make sure your environment meets [system requirements](system-requirements.md).

1. [Set up a deployment environment](#configure-a-deployment-machine)
1. [Configure hosts](#configure-hosts)
1. [Install Launchpad](#set-up-mirantis-launchpad-cli-tool)
1. [Create a Launchpad configuration file](#create-the-cluster-configuration-file)
1. [Bootstrap your cluster](#bootstrap-your-cluster)
1. [Connect to your cluster](#interact-with-your-cluster)

## Set up a deployment environment

To fully evaluate and use Docker Enterprise, we recommend installing Launchpad on a Linux, Mac, or Windows machine or virtual machine (VM) able to run the following.

* A graphic desktop and browser, for accessing or installing:
  * The Docker Enterprise Universal Control Plane web ui
  * [Lens](https://k8slens.dev/), an open source, stand-alone GUI application from Mirantis (available for Linux, Mac, and Windows) for multi-cluster management and operations
  * Metrics, observability, visualization and other tools
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/), the Kubernetes command-line client
* curl, [Postman](https://www.postman.com/) and/or [client libraries](https://kubernetes.io/docs/reference/using-api/client-libraries/) for accessing the Kubernetes REST API
* [Docker](https://docs.docker.com/get-docker/) and related tools, for using the 'docker swarm' CLI, and for containerizing workloads and accessing local and remote registries.

This machine can reside in different contexts from the hosts and connect with them in several different ways, depending on the infrastructure and services you use.

This machine must be able to communicate with your hosts via their IP addresses on several ports. Depending on your infrastructure and security requirements, this can be relatively simple to achieve for evaluation clusters. See [Networking Considerations](networking-considerations.md) for more.

## Configure hosts

A Docker Enterprise cluster is comprised of at least one manager node and one or more worker nodes. To begin, we recommend deploying a small evaluation cluster, with one Manager and at least one worker node. This will give you an opportunity to familiarize yourself quickly with Launchpad, with procedures for provisioning nodes, and with Docker Enterprise features (and, if you're deploying on a public cloud, minimizing costs).

Ultimately, Launchpad can deploy Docker Enterprise Manager and Worker nodes in any combination, creating many different cluster configurations. For example:

* _Small evaluation clusters_, with one Manager and one or more Worker nodes
* _Diverse clusters_, with Linux and Windows Workers
* _High-availability clusters_, with two, three, or more Manager nodes
* _Clusters that Launchpad can auto-update, non-disruptively_, with multiple Managers (allowing one-by-one update of the control plane without loss of cluster cohesion) and sufficient Worker nodes of each type to let workloads be drained to new homes as each node is updated

Your hosts must be able to communicate with one another (and potentially, with users in the outside world) on their IP addresses, using many ports. Depending on your infrastructure and security requirements, this can be relatively simple to achieve for evaluation clusters. See [Networking Considerations](networking-considerations.md).


## Install Launchpad

UCP clusters may be deployed, managed and maintained with the Mirantis Launchpad ("**launchpad**") CLI tool. This tool is updated regularly, so make sure you are always using the latest version.

**Note:** Launchpad has built-in telemetry for tracking the usage of the tool. The telemetry data is used to improve the product and overall user experience. No sensitive data about the clusters is included in the telemetry payload.

1. [Download Launchpad](https://github.com/Mirantis/launchpad/releases/latest)
1. Rename the downloaded binary to `launchpad`, move it to a directory in your PATH variable, and give it permission to run (execute permission).
1. If you are using macOS you may also have to give Launchpad permissions in the **Security & Privacy** section in **System Preferences**.

Once installed, verify the installation by checking the installed tool version using the `launchpad version` command.

```
$ launchpad version

# console output:

version: 1.0.0
```

To finalize the installation, complete the registration. The information you provide in registration is used to assign evaluation licenses and to provide help for using Launchpad. Use `launchpad register` command to complete the registration.

```
$ launchpad register

name: Luke Skywalker
company: Jedi Corp
email: luke@example.com
I agree to Mirantis Launchpad Software Evaluation License Agreement https://github.com/Mirantis/launchpad/blob/master/LICENSE [Y/n]: Yes
INFO[0022] Registration completed!
```

## Create a Launchpad configuration file

The cluster is configured using [a yaml file](configuration-file.md). In this example we setup a simple 2 node UCP cluster using Kubernetes. One node is used for UCP and one is a worker node.

Open up your favorite editor, and type something similar to the example below. Once done, save the file as `launchpad.yaml`. Adjust the example below to meet your infrastructure requirements. This model should work to deploy hosts on most public clouds.

```yaml
apiVersion: launchpad.mirantis.com/v1
kind: DockerEnterprise
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

If you're deploying on VirtualBox or other desktop virtualization solution and are using ‘bridged’ networking, you’ll need to make a few minor adjustments to your launchpad.yaml (see below) — deliberately setting a –pod-cidr to ensure that pod IP addresses don’t overlap with node IP addresses (the latter are in the 192.168.x.x private IP network range on such a setup), and supplying appropriate labels for the target nodes’ private IP network cards using the privateInterface parameter (this typically defaults to ‘enp0s3’ on Ubuntu 18.04 &mdash; other Linux distributions use similar nomenclature). You may also need to set the username to use for logging into the host.

```yaml
apiVersion: launchpad.mirantis.com/v1
kind: DockerEnterprise
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
For more complex setups, Launchpad has a full set of [configuration options](configuration-file.md).

If you are familiar with [Terraform](https://www.terraform.io/), you can automate the infrastructure creation using our [Terraform examples](../examples/terraform/README.md) as a baseline.

## Bootstrap your cluster

Once the cluster configuration file is ready, we can fire up the cluster. In the same directory where you created the `launchpad.yaml` file, run:

```
$ launchpad apply
```

The `launchpad` tool uses with SSH or WinRM to connect to the infrastructure you've specified in the `launchpad.yaml` and configures everything needed on the hosts. Within few minutes you should have your cluster up and running.

## Connect to your cluster

At the end of the installation procedure, launchpad will show you the details you can use to connect to your cluster. You will see something like this:
```
INFO[0021] ==> Running phase: UCP cluster info
INFO[0021] Cluster is now configured.  You can access your admin UIs at:
INFO[0021] UCP cluster admin UI: https://test-ucp-cluster-master-lb-895b79a08e57c67b.elb.eu-north-1.amazonaws.com
INFO[0021] You can also download the admin client bundle with the following command: launchpad download-bundle --username <username> --password <password>
```

By default, the admin username is `admin`. If you did not supply the password in with `launchpad.yaml` or via the `installFlags` option like `--admin-password=supersecret`, the generated admin password will be displayed in the install flow:
```
INFO[0083] 127.0.0.1:  time="2020-05-26T05:25:12Z" level=info msg="Generated random admin password: wJm-TzIzQrRNx7d1fWMdcscu_1pN5Xs0"
```
