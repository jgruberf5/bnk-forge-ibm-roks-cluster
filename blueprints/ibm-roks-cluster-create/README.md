# IBM ROKS Cluster Provisioning Blueprint

Forge **hybrid Stage 1 + Stage 2** blueprint. Creates a new IBM ROKS cluster *and* installs the BNK platform onto it in one apply. The catalog files this under **① Infrastructure** because cluster provisioning is the front-loaded work; the bundled Stage 2 modules are listed under "What You Get" below.

## What You Get

### Stage 1 — Infrastructure

- A new IBM ROKS cluster (`modules/roks-cluster-create`)
- Existing IBM COS instance referenced by name for the cluster registry
- Outputs compatible with BNK managed-cluster registration

### Stage 2 — BNK Platform (bundled)

- `cert-manager` installed in the new cluster, with its CRDs registered (`modules/roks-cluster-install-cert-manager`)
- F5 Lifecycle Operator (FLO) installed and bound to an IBM IAM trusted profile (`modules/roks-cluster-install-flo`)
- A CNEInstance deployed, with its TMM/Helm pods reaching Ready (`modules/roks-cluster-cneinstall`)
- A BNK License CR applied to the cluster, using the JWT stored in IBM COS (`modules/roks-cluster-license`)

## Lifecycle Stage

If you already have a ROKS cluster, use `ibm-roks-existing-cluster` instead — it skips the cluster-create module and runs only the Stage 2 work.

## Next Step

After apply succeeds, run BNK managed-cluster detection to register the created cluster into the Kubernetes inventory.
