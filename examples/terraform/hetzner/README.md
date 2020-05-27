# Bootstrapping UCP cluster on Hetzner

This directory provides an example flow with Mirantis Launchpad tool together with Terraform using [Hetzner](https://www.hetzner.com/cloud) as the cloud provider.


## Pre-requisites

* You need an account and API token for Hetzner
* Terraform [installed](https://learn.hashicorp.com/terraform/getting-started/install)
* [yq installed](https://github.com/mikefarah/yq#install)

## Steps

1. Create terraform.tfvars file with needed details. You can use the provided terraform.tfvars.example as a baseline.
2. `terraform init`
3. `terraform apply`
4. `terraform output -json | yq r --prettyPrint - ucp_cluster.value > cluster.yaml `
5. `launchpad apply`
6. Profit! :)

