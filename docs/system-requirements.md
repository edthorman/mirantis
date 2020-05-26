# System Requirements

Mirantis Launchpad is a static binary that works on following operating systems:

* Linux (x64)
* MacOS (x64)
* Windows (x64)

## System Requirements for UCP Clusters

### Supported Operating Systems

* CentOS 7
* CentOS 8
* Ubuntu 18.04.x
* Redhat Enterprise Linux 7.x
* Redhat Enterprise Linux 8.x
* Windows Server 2019

### Hardware Requirements

#### Minimum

* 8GB of RAM for manager nodes
* 4GB of RAM for worker nodes
* 2 vCPUs for manager nodes
* 10GB of free disk space for the /var partition for manager nodes (A minimum of 6GB is recommended.)

#### Recommended for Production

* 16GB of RAM for manager nodes
* 4 vCPUs for manager nodes
* 25-100GB of free disk space

Note that Windows container images are typically larger than Linux container images. For this reason, you should provision more local storage for Windows nodes.

### Ports Used

When installing an UCP cluster, a series of ports need to be opened to incoming traffic. See [UCP documentation](https://docs.docker.com/ee/ucp/admin/install/system-requirements/#ports-used) for more details.

