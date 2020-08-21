# Upgrading clusters with Mirantis Launchpad

Mirantis Launchpad allows users to upgrade their clusters with  single `launchpad apply` reconciliation command. The tool itself will discover the current state of the cluster and all it's components and will upgrade what is needed.

## Upgrading the Docker EE Engine

Say you want to upgrade the Docker EE engine running in the cluster. You've bootsrapped the cluster with version `19.03.8` and want to upgrade to say `19.03.14`. What you'd need to do is to bump the engine version in your `cluster.yaml` file:

```yaml
apiVersion: launchpad.mirantis.com/v1beta3
kind: DockerEnterprise
metadata:
  name: launchpad-ucp
spec:
  hosts:
  - address: 10.0.0.1
    role: manager
  engine:
    version: 19.03.14 # was previously 19.03.8
```
Once the file is ready, just re-run `launchpad apply` command. Launchpad will upgrade the engine instalation on all hosts in steps. First it will upgrade the engine on each manager node one-by-one, in multi-manager case only single manager gets "down" during the process. For worker nodes it will run the upgrade process for 10% of the nodes at time. So during the engine upgrade, 10% of the nodes might be "down" for a short while.

## Upgrading UCP or DTR components

When a newer version of UCP or DTR is available you need to just bump the associated version tag in the `cluster.yml`:

```yaml
apiVersion: launchpad.mirantis.com/v1beta3
kind: DockerEnterprise
metadata:
  name: launchpad-ucp
spec:
  hosts:
  - address: 10.0.0.1
    role: manager
  ucp:
    version: 3.3.1
  dtr:
    version: 2.8.1
```

Once the file is ready, just re-run `launchpad apply` command. Launchpad will connect to the nodes and discovers the current cluster state and will notice we need to upgrade components. It will run the required upgraders and within few minutes your cluster will be upgraded to the given version.

**Note:** Both UCP and DTR components only support upgrades for one minor (`y` in `x.y.z`) bumps in the upgrade so make sure you're not trying to hop too far at once.

## Upgrading Docker EE engine, UCP and DTR at the same time

It is possible to upgrade the engine, UCP and DTR components within the same `launchpad apply` run. Launchpad will first upgrade the engines on all the nodes as described above and only after that it will upgrade UCP components, then finally DTR components.
