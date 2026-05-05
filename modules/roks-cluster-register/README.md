# IBM ROKS Existing Cluster Registration Module

References an existing IBM ROKS cluster and emits the output fields BNK Forge needs to register the cluster in the Kubernetes inventory.

This module intentionally does not create IBM resources. It only resolves:

- the existing cluster metadata
- the cluster public API endpoint
- BNK-compatible cluster registration outputs

After apply succeeds, run BNK managed-cluster detection to register the cluster.
