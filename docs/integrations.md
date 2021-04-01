# Integrating with Mirantis Launchpad

Mirantis Launchpad is distributed as a binary executable. The main integration point with cluster management is the `launchpad apply` command and the input [`launchpad.yaml`](configuration-file.md) configuration for the cluster. As the configuration is in YAML format you can integrate other tooling with it. One of the common use cases uses infrastructure management tooling such as Terraform.

## Terraform with Mirantis Launchpad

When using cloud environments many people use [Terraform](https://www.terraform.io/) to manage the infrastructure declaratively. The easiest way to integrate Terraform to Mirantis Launchpad is to use [Terraform output](https://www.terraform.io/docs/configuration/outputs.html) values to specify the whole [`launchpad.yaml`](configuration-file.md) structure.

```terraform
locals {
  managers = [
    for host in module.masters.machines : {
      ssh = {
        address = host.public_ip
        user    = "ubuntu"
        keyPath = "./ssh_keys/${var.cluster_name}.pem"
      }
      role             = host.tags["Role"]
      privateInterface = "ens5"
    }
  ]
  workers = [
    for host in module.workers.machines : {
      ssh = {
        address = host.public_ip
        user    = "ubuntu"
        keyPath = "./ssh_keys/${var.cluster_name}.pem"
      }
      role             = host.tags["Role"]
      privateInterface = "ens5"
    }
  ]
  windows_workers = [
    for host in module.windows_workers.machines : {
      winRM = {
        address = host.public_ip
        user     = "Administrator"
        password = var.windows_administrator_password
        useHTTPS = true
        insecure = true
      }
      role             = host.tags["Role"]
      privateInterface = "Ethernet 2"
    }
  ]
  launchpad_tmpl = {
    apiVersion = "launchpad.mirantis.com/mke/v1.3"
    kind       = "mke"
    spec = {
      mke = {
        adminUsername = "admin"
        adminPassword = var.admin_password
        installFlags : [
          "--default-node-orchestrator=kubernetes",
          "--san=${module.masters.lb_dns_name}",
        ]
      }
      hosts = concat(local.managers, local.workers, local.windows_workers)
    }
  }
}

output "mke_cluster" {
  value = yamlencode(local.launchpad_tmpl)
}
```

To run launchpad with the generated configuration, use:

```
terraform output mke_cluster | launchpad apply -c -
```

Launchpad will install all the needed cluster components.

You can see real-life examples for using Terraform with Mirantis Launchpad in [Terraform Examples](../examples/terraform/README.md).
