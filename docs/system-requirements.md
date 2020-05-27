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

### SSH

Launchpad will connect to machines via SSH. Thus, SSH is required to be enabled on host machines. Only password-less sudo capable SSH Key-Based authentication is supported.

#### Windows Machines
To enable SSH easily on Windows machines, you can look the following PowerShell snippets and modify them for your own needs and run it on each Windows machine:

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

After that you need to transfer your SSH public key from your local machine to host machines:

```
# Transfer SSH Key to Server
scp ~/.ssh/id_rsa.pub Administrator@1.2.1.2:C:\Users\Administrator\.ssh\authorized_keys
ssh --% Administrator@1.2.1.2 powershell -c $ConfirmPreference = 'None'; Repair-AuthorizedKeyPermission C:\Users\Administrator\.ssh\authorized_keys
```

To read more how to manage Windows with OpenSSH, you can refer the official documentation: https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_overview

### Ports Used

When installing an UCP cluster, a series of ports need to be opened to incoming traffic. See [UCP documentation](https://docs.docker.com/ee/ucp/admin/install/system-requirements/#ports-used) for more details.

