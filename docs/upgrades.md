# Upgrade components with Mirantis Launchpad

Mirantis Launchpad allows users to upgrade their clusters with the `launchpad apply` reconciliation command. The tool itself will discover the current state of the cluster and all it's components and will upgrade what is needed.

## Upgrading Docker Engine - Enterprise

To upgrade Docker Engine - Enterprise, change the engine version in the `launchpad.yaml` file.

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
    version: 19.03.12 # was previously 19.03.8
```
After you update `launchpad.yaml`, you can run `launchpad apply`. Launchpad will upgrade the engine on all hosts in a specific sequence.

1. Upgrade the engine on each manager node one-by-one. This means that if you have more than one manager node, the other manager nodes are available while the first node is updated.

2. After the first manager node is updated and running again, the second is updated, and so on until all of the manager nodes are running the new version of the engine.

3. 10% of worker nodes are updated at a time until all of the worker nodes are running the new version of engine.

## Upgrading UCP or DTR

When a newer version of UCP or DTR is available you can upgrade to it by changing the version tags in the `launchpad.yaml`:

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

1. Update the version tags and save `launchpad.yaml`.

2. Run the `launchpad apply` command.

3. Launchpad connects to the nodes gets the current version of each component.

4. Launchpad upgrades each node as described in the "Upgrading Docker Engine - Enterprise" section. This may take several minutes.

**Note:** UCP and DTR upgrade paths require consecutive minor versions. For example, you cannot upgrade from UCP 3.1.0 to 3.1.2; you must upgrade from UCP 3.1.0 to 3.1.1 to 3.1.2.

## Upgrading Docker Engine - Enterprise, UCP, and DTR together

You can upgrade all of the components -- engine, UCP, and DTR -- at the same time.

1. Update `launchpad.yaml`, as shown in the previous sections.

2. Run the `launchpad apply` command.

3. Launchpad upgrades the engines on all the nodes as described in the "Upgrading Docker Engine - Enterprise" section.

4. Launchpad upgrades UCP on all nodes.

5. Launchpad upgrades DTR.
