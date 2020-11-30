# System Requirements for Mirantis Launchpad

Mirantis Launchpad is a static binary that works on following operating systems:

* Linux (x64)
* MacOS (x64)
* Windows (x64)

## MKE requirements
In addition to the requirement for running Launchpad, you must also meet the system requirements for MKE.

### Supported Operating Systems for MKE

MKE can be installed on the following operating systems.

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

### Remote management

Launchpad connects to Linux machines via SSH and to Windows machines via SSH or WinRM so you need to set up one of them on host instances.

**Note:** Only passwordless sudo capable SSH Key-Based authentication is currently supported. On Windows the user needs to have Administrator privileges.

#### Windows setup for SSH or WinRM

##### OpenSSH

[OpenSSH](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_overview) is the open-source version of the Secure Shell (SSH) tools used by administrators of Linux and other non-Windows for cross-platform management of remote systems, and is included in Windows Server 2019.

1. To enable SSH on Windows, you can run the following PowerShell snippets, modified for your specific configuration, on each Windows host.

```
# Install OpenSSH
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

# Configure ssh key authentication
mkdir c:\Users\Administrator\.ssh\
$sshdConf = 'c:\ProgramData\ssh\sshd_config'
(Get-Content $sshdConf).replace('#PubkeyAuthentication yes', 'PubkeyAuthentication yes') | Set-Content $sshdConf
(Get-Content $sshdConf).replace('Match Group administrators', '#Match Group administrators') | Set-Content $sshdConf
(Get-Content $sshdConf).replace('       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys', '#       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys') | Set-Content $sshdConf
restart-service sshd
```

2. Transfer your SSH public key from your local machine to the host, using the following example but with your own values.

```
# Transfer SSH Key to Server
scp ~/.ssh/id_rsa.pub Administrator@1.2.1.2:C:\Users\Administrator\.ssh\authorized_keys
ssh --% Administrator@1.2.1.2 powershell -c $ConfirmPreference = 'None'; Repair-AuthorizedKeyPermission C:\Users\Administrator\.ssh\authorized_keys
```

##### WinRM

As an alternative to SSH, you can use [WinRM](https://docs.microsoft.com/en-us/windows/win32/winrm/portal) can be also used on Windows hosts as an alternative to SSH.

### Ports Used

When installing a MKE cluster, a series of ports need to be opened to incoming traffic. See [MKE documentation](https://docs.mirantis.com/docker-enterprise/v3.1/dockeree-products/ucp/install-ucp.html#ports-used) for more details.

