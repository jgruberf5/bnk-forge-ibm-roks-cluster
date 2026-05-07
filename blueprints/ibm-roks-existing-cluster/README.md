# IBM ROKS Existing Cluster Registration Blueprint

Forge **Stage 2 (Platform / BNK)** blueprint. References an existing IBM ROKS cluster and installs the BNK platform onto it.

## What You Get

- Existing IBM ROKS cluster metadata resolved from IBM Cloud (`modules/roks-cluster-register`)
- Outputs compatible with BNK managed-cluster registration
- `cert-manager` installed in the cluster, with its CRDs registered (`modules/roks-cluster-install-cert-manager`)
- F5 Lifecycle Operator (FLO) installed and bound to an IBM IAM trusted profile (`modules/roks-cluster-install-flo`)
- A CNEInstance deployed, with its TMM/Helm pods reaching Ready (`modules/roks-cluster-cneinstall`)
- A BNK License CR applied to the cluster, using the JWT stored in IBM COS (`modules/roks-cluster-license`)

## Lifecycle Stage

This is a Stage 2 (Platform / BNK) blueprint — it assumes a ROKS cluster already exists. To create the cluster as well, use `ibm-roks-cluster-create` instead.

## Next Step

After apply succeeds, run BNK managed-cluster detection to register the referenced cluster into the Kubernetes inventory.
