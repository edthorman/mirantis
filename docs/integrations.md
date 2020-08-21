# Integrating with Mirantis Launchpad

Currently Mirantis Launchpad is distributed only as a binary executable. Hence the main integration point with cluster management is the `launchpad apply` command and the input [`cluster.yaml`](configuration-file.md) configuration for the cluster. As the configuration is in YAML format it should be pretty easy to integrate other tooling with it. One of the most common use cases is when using some infrastructure management tooling such as Terraform.

## Terraform with Mirantis Launchpad

When using cloud environments many people are using [Terraform](https://www.terraform.io/) to manage the infrastructure declaratively. The easiest way to integrate Terraform to Mirantis Launchpad is to use [Terraform output](https://www.terraform.io/docs/configuration/outputs.html) values to specify the whole [`cluster.yaml`](configuration-file.md) structure. For example:
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

Unfortunately Terraform only currently outputs json format so we need to convert that into yaml with a little helper tool called [`yq`](https://github.com/mikefarah/yq). With a simple command piping we can take the Terraform output and convert it to `cluster.yaml`:
```
terraform output -json | yq r --prettyPrint - ucp_cluster.value > cluster.yaml
```

Now we can feed that into `launchpad apply` and Launchpad will go and install all the needed cluster components.

For real-life examples for using Terraform with Mirantis Launchpad you can head over to [Terraform Examples](../examples/terraform/README.md)
