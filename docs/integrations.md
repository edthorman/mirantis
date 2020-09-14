# Integrating with Mirantis Launchpad

Mirantis Launchpad is distributed as a binary executable. The main integration point with cluster management is the `launchpad apply` command and the input [`launchpad.yaml`](configuration-file.md) configuration for the cluster. As the configuration is in YAML format you can integrate other tooling with it. One of the common use cases uses infrastructure management tooling such as Terraform.

## Terraform with Mirantis Launchpad

When using cloud environments many people use [Terraform](https://www.terraform.io/) to manage the infrastructure declaratively. The easiest way to integrate Terraform to Mirantis Launchpad is to use [Terraform output](https://www.terraform.io/docs/configuration/outputs.html) values to specify the whole [`launchpad.yaml`](configuration-file.md) structure. 

```terraform
output "ucp_cluster" {
  value = {
    apiVersion = "launchpad.mirantis.com/v1beta3"
    kind = "UCP"
    spec = {
      ucp = {
        installFlags: [
          "--admin-username=admin",
          "--admin-password=${var.admin_password}",
          "--default-node-orchestrator=kubernetes",
          "--san=${module.managers.lb_dns_name}",
        ]
      }
      hosts = concat(local.managers, local.workers)
    }
  }
}
```

Terraform is currently limited to output json format. To convert the json to yaml, you can use a tool called [`yq`](https://github.com/mikefarah/yq) that converts the json to yaml so you can use command piping to convert the Terraform output to `launchpad.yaml`.

```
terraform output -json | yq r --prettyPrint - ucp_cluster.value > launchpad.yaml
```

You can now use the `launchpad apply` command, and Launchpad will install all the needed cluster components.

You can see real-life examples for using Terraform with Mirantis Launchpad in [Terraform Examples](../examples/terraform/README.md).
