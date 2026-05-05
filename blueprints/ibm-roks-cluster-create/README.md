# IBM ROKS Cluster Provisioning Blueprint

Creates a new IBM ROKS cluster using the `modules/roks-cluster-create` deployment pack.

## What You Get

- A new IBM ROKS cluster
- Existing IBM COS instance referenced by name for the cluster registry
- Outputs compatible with BNK managed-cluster registration

## Next Step

After apply succeeds, run BNK managed-cluster detection to register the created cluster into the Kubernetes inventory.
