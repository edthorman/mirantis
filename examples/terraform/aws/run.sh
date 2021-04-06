#!/usr/bin/env sh

terraform apply -auto-approve
mv -i ./launchpad.new.yaml ./launchpad.$(date +"%Y-%m-%d_%H-%M").yaml
# terraform output mke_cluster | sed '1d;$d' > ./launchpad.yaml
terraform output -json | yq e -P '.mke_cluster.value' - > ./launchpad.yaml && launchpad describe config > ./launchpad.new.yaml
