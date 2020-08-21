# Bootstrapping UCP cluster on AWS

This directory provides an example flow with Mirantis Launchpad together with Terraform and Openstack.

## Pre-requisites

* You need an account and credentials for an Openstack Tenant.
* Terraform [installed](https://learn.hashicorp.com/terraform/getting-started/install)
* [yq installed](https://github.com/mikefarah/yq#install)
* [Generate SSH key](https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key)

## Steps

1. Create terraform.tfvars file with needed details. You can use the provided terraform.tfvars.example as a baseline.
2. `terraform init`
3. Create SSH key and configure path
4. Create Cloud Provider config file and configure path 
5. Configure .tfvars file with all necessary parameters
6. `terraform apply`
7. `terraform output -json | yq r --prettyPrint - ucp_cluster.value > cluster.yaml`
8. `launchpad apply`
9. Profit! :)

# Links
1. [Howto generate SSH key](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
2. Configure [Openstack Cloud Provider](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/getting-started-provider-dev.md) config
