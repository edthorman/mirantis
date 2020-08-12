# Networking considerations

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

If you intend to deploy a cluster for longer-term evaluation, it makes sense to secure it more deliberately. In this case, a certain range of ports will need to be opened on hosts. Please see [System Requirements: Ports Used](system-requirements.md#ports-used) for links to documentation.

#### Using DNS

Launchpad can deploy certificate bundles obtained from a certificate provider to authenticate your cluster. These can be used in combination with DNS to let you reach your cluster securely on a fully-qualified domain name (FQDN). See [UCP documentation](https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/ucp/ucp-configure/add-sans-to-cluster-certs.html) for more information.
