# IBM ROKS Cluster Blueprint

Forge **Stage 1 (Infrastructure)** blueprint. Creates a new IBM ROKS cluster using the `modules/roks-cluster-create` deployment pack.

## What You Get

- A new IBM ROKS cluster
- The cluster registry references an existing IBM COS instance by name
- Outputs compatible with BNK managed-cluster registration

## Lifecycle Stage

This blueprint only provisions the cluster. To install the BNK platform (cert-manager, FLO, CNEInstance, License) onto a cluster — whether the one created here or a pre-existing one — deploy `ibm-roks-existing-cluster` next.

## Next Step

After apply succeeds, run BNK managed-cluster detection to register the created cluster into the Kubernetes inventory, then deploy `ibm-roks-existing-cluster` to install the BNK platform.
