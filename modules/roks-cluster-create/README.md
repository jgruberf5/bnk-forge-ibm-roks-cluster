# IBM ROKS Cluster Create Module

Creates an IBM ROKS cluster and emits the output fields BNK Forge needs to register the created cluster in the Kubernetes inventory.

This module intentionally focuses on cluster creation only:

- IBM Cloud API key authentication
- region and resource group selection
- existing IBM COS instance lookup by name for the registry
- BNK-compatible cluster registration outputs

After apply succeeds, run BNK managed-cluster detection to register the created cluster.
