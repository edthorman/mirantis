# Node Management with Mirantis Launchpad

Adding and removing nodes is highly dependent on the roles of the nodes. The following chapters cover the process of adding and removing nodes in different roles.

### Notes on Manager Nodes

Swarm manager nodes use the Raft Consensus Algorithm to manage the swarm state. You only need to understand some general concepts of Raft in order to manage a swarm.

There is no limit on the number of manager nodes. The decision about how many manager nodes to implement is a trade-off between performance and fault-tolerance. Adding manager nodes to a swarm makes the swarm more fault-tolerant. However, additional manager nodes reduce write performance because more nodes must acknowledge proposals to update the swarm state. This means more network round-trip traffic.

Raft requires a majority of managers, also called the quorum, to agree on proposed updates to the swarm, such as node additions or removals. Membership operations are subject to the same constraints as state replication.

Keep in mind that the manager nodes also host the control plane etcd cluster. Even more importantly, any changes to the cluster require a working etcd cluster with the majority of peers present and working.

As normally with quorum based systems, it is highly advisable to run an odd number of peers. As the control plane only works when a majority can be formed, once you grow the control plane to have more than one node, you can't (automatically) go back to having only one node.

### Adding Manager Nodes

Adding manager nodes is as simple as adding them into the `cluster.yaml`. Re-running `launchpad apply ...` will configure the control plane on the new node and also makes necessary changes in the swarm & etcd cluster.

### Removing Manager Nodes

Once you've determined that it is safe to remove a manager node, and its etcd peer, follow this process:

1. Remove the manager host from `cluster.yaml`
2. Run `launchpad apply --prune ...`
3. Terminate/remove the node in your infrastructure

### Adding Worker Nodes

Adding worker nodes is as simple as adding them into the `cluster.yaml`. Re-running `launchpad apply ...` will configure everything on the new node and joins it into the cluster.

### Removing Worker Nodes

Removing a worker node is currently a multi step process:

1. Remove the host from `cluster.yaml`.
2. Run `launchpad apply --prune ...`
3. Terminate/remove the node in your infrastructure




