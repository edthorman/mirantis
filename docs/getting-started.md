# Getting Started With Mirantis Launchpad

Mirantis Launchpad is designed to work on any infrastructure: private datacenters, public cloud, hybrid or edge. It works on any environment that will meet the minimum [system requirements](system-requirements.md) and allows you to bootstrap and manage your clusters very easily.

Get started by following these steps:

1. [Setup Mirantis Launchpad CLI tool](#setup-mirantis-launchpad-cli-tool)
2. [Prepare nodes for your cluster](#prepare-nodes-for-your-cluster)
3. [Create the cluster configuration file](#create-the-cluster-configuration-file)
4. [Bootstrap your cluster](#bootstrap-your-cluster)
5. [Interact with your cluster](#interact-with-your-cluster)

For custom deployments, see [manual installation instructions]().

## Setup Mirantis Launchpad CLI Tool

UCP clusters may be deployed, managed and maintained with the Mirantis Launchpad ("**launchpad**") CLI tool. This tool is updated regularly so make sure you are always using the latest version.

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

## Prepare nodes for your cluster

In order to install UCP cluster, you'll need some machines. You can provision those machines from your favourite public cloud provider or use your private datacenter. Any machines with one of the [supported operating systems](system-requirements.md#supported-host-operating-systems-for-ucp-clusters) may be used. We recommend at minimum 2 machines.

## Create the cluster configuration file

The cluster is configured using [a yaml file](configuration-file.md). In this example we setup simple 1+1 UCP Kubernetes cluster, one node acts as the UCP control plane and one as pure worker node.

Open up your favourite editor, and type something similar as in the example below. Once done, save the file as `cluster.yaml`. Naturally you need to adjust the example below to match your infrastructure details.

```yaml
apiVersion: launchpad.mirantis.com/v1beta1
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
  - address: 192.168.110.100
    role: manager
    sshKeyPath: ~/.ssh/my_key
  - address: 192.168.110.101
    role: worker
    sshKeyPath: ~/.ssh/my_key
```

For more complex setups, there's a huge amount of [configuration options](configuration-file.md) available.

## Bootstrap your cluster

Once the cluster configuration file is ready, we can fire up the cluster. In the same directory where you created the `cluster.yaml` file, run:

```
$ launchpad apply
```

The `launchpad` tool connects to the infrastructure you've specified in the `cluster.yaml` with SSH connections and configures everything needed on the hosts. Within few minutes you should have your cluster up-and-running.

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

