# Host configuration checklist

Launchpad target hosts must be provisioned with:

* _Sufficient vCPU, RAM, and SSD storage_ &mdash; See [system requirements](system-requirements.md) for details. For a small evaluation cluster, Manager and Workers can be provisioned with 2 vCPUs, 8GB RAM, with a 20GB SSD. On AWS EC2, for example, these specifications are met by a t3.large instance type, with SSD storage expanded to 20GB from the default 10GB. Note that, for long-term evaluation, you should provision hosts with a minimum of 64GB mass storage so that log rotation can occur. See below.
* _A supported operating system_ &mdash; Docker Enterprise Manager nodes run on a supported Linux (see [system requirements](system-requirements.md)). Worker nodes may, alternatively, run on Windows Server 2019. Note that if you intend to deploy on desktop virtualization (e.g., VirtualBox), you will need to download a supported Linux server OS as an ISO file, mount it to boot from a virtual DVD drive, and install the operating system onto the VM SSD at first launch.

Hosts must be configured to allow:

* _Access via SSH (for Windows hosts you can also use WinRM):_
  - Public and private cloud Linux images are usually configured to enable SSH access by default.
  - Public and private cloud Windows Server images are normally configured for WinRM by default, which Launchpad supports.
  - If installing Linux on a desktop (e.g., VirtualBox) VM, you will need to install and enable the SSH server (e.g., OpenSSH) as part of initial OS installation, or access the running VM via the built-in remote terminal and install, configure, and enable OpenSSH manually, later. Google 'install ssh server &lt;your chosen Linux&gt;' for OS-specific tutorials and instructions.
  - Alternatively, Launchpad also supports SSH connections to Windows Server hosts. Enabling SSH on Windows Server will typically require post-launch configuration, and can be scripted for enablement at VM launch. See [system requirements](system-requirements.md) or [this blog](https://www.mirantis.com/blog/today-i-learned-how-to-enable-ssh-with-keypair-login-on-windows-server-2019/).
  - Launchpad can also use the local host without a remote connection

* _For hosts accessed via SSH: remote login using private key:_ &mdash; Launchpad, like most deployment tools, uses encryption keys rather than passwords to authenticate to hosts. You will need to create or use an existing keypair, copy the public key to an appropriate location on each host, configure SSH on hosts to permit SSH authentication using a key instead of a password(then restart the sshd server), and store the keypair (or just the private key) in an appropriate location on your deployer machine, with appropriate permissions. Google 'enable SSH with keys &lt;your chosen Linux&gt;' for OS-specific tutorials and instructions on creating and using SSH keypairs.
  - Keywise login is the default for Linux instances on most public and private cloud platforms. Typically, you can use the platform to create an SSH keypair (or upload a private key created elsewhere, e.g., on your deployer machine), and assign this key to VMs at launch.
  - For Linux hosts on desktop virtualization, assuming you're installing a new OS on each VM, you'll need to configure keywise SSH access after installing OpenSSH. This entails creating a private key, copying it to each host, then reconfiguring SSH on each host to use private keys instead of passwords before restarting the sshd service.
  - For Windows hosts, access via SSH and keys must be configured manually after first boot, or can be automated. See [system requirements](system-requirements.md) or [this blog](https://www.mirantis.com/blog/today-i-learned-how-to-enable-ssh-with-keypair-login-on-windows-server-2019/). It's also possible to use WinRM for connecting to Windows hosts.

* _For Linux hosts: passwordless sudo_ &mdash; Most Linux operating systems now default to enabling login by a privileged user with sudo permissions, rather than by 'root.' This is safer than permitting direct login by root (which is also prevented by the default configuration of most SSH servers). Launchpad requires that the user be allowed to issue 'sudo' commands without being prompted to enter a password.
  - This is the default for Linux instances on most public and private cloud platforms. The username you create at VM launch will have passwordless sudo privileges.
  - If installing Linux on a desktop (e.g., VirtualBox) VM, you will typically need to configure passwordless sudo after first boot of a newly-installed OS. Google 'configure passwordless sudo &lt;your chosen Linux&gt;' for tutorials and instructions.
  - On Windows hosts, the Administrator account is given all privileges by default, and Launchpad can escalate permissions at need without a password. If when using WinRM you get `http 401` error, it is possibly due to a password policy. You need to have a sufficiently complex password, such as `,,UCP..Example123..`.

* _Configure Docker logging to enable auto-rotation and manage retention_ * &mdash; Additionally, we recommend configuring evaluation hosts, especially those with smaller SSDs/HDDs, to enable basic Docker log rotation and managing old-file retention, thus avoiding filling up cluster storage with retained logs.

This can be done by defining Docker engine configuration in launchpad.yaml, for example:

```yaml
...

spec:
  hosts:
  - address: 192.168.110.100
    role: manager
    ssh:
      keyPath: ~/.ssh/id_rsa
      user: theuser
    privateInterface: enp0s3
    engineConfig:
      log-driver: json-file
      log-opts:
        max-size: "10m"
        max-file: "3"
...
```
