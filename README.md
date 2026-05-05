# BNK Forge IBM ROKS Cluster

Forge-ready IBM ROKS content focused on two outcomes only:

- create a new IBM ROKS cluster and emit BNK-compatible registration outputs
- reference an existing IBM ROKS cluster and emit BNK-compatible registration outputs

## Repository Contents

- `modules/roks-cluster-create`
  Creates an IBM ROKS cluster using an existing IBM COS instance for the OpenShift registry.

- `modules/roks-cluster-register`
  Resolves an existing IBM ROKS cluster by name or ID and emits the outputs BNK Forge needs for managed-cluster registration.

- `blueprints/ibm-roks-cluster-create`
  Blueprint that creates a new IBM ROKS cluster.

- `blueprints/ibm-roks-existing-cluster`
  Blueprint that references an existing IBM ROKS cluster.

## Design Goals

- keep the repository limited to cluster creation and cluster registration only
- use IBM Cloud API key authentication with region and resource group inputs
- use an existing COS instance name for the create-cluster flow
- emit the output fields BNK Forge needs to register the cluster in the Kubernetes inventory

## Layout

```text
bnk-forge-ibm-roks-cluster-4/
  modules/
    roks-cluster-create/
      bnkforge.pack.json
      README.md
      main.tf
      variables.tf
      outputs.tf
    roks-cluster-register/
      bnkforge.pack.json
      README.md
      main.tf
      variables.tf
      outputs.tf
  blueprints/
    ibm-roks-cluster-create/
      forge-blueprint.json
      README.md
    ibm-roks-existing-cluster/
      forge-blueprint.json
      README.md
```

## BNK Registration Requirement

BNK Forge registers IBM ROKS clusters from applied module outputs. Both modules in this repository emit the required fields:

- `cluster_name`
- `cluster_id`
- `openshift_cluster_public_endpoint`
- `region`

After apply succeeds, run BNK managed-cluster detection to create the Kubernetes cluster entry.

## IBM Cloud Credential Template Compatibility

Both modules and both blueprints intentionally use the BNK Forge IBM credential-template variable names:

- `ibmcloud_api_key`
- `ibmcloud_cluster_region`
- `ibmcloud_resource_group`

That lets BNK Forge prefill these values from the selected IBM Cloud Credential Template in both flows:

- Add Module to Project
- Imported Blueprint deployment

## Import into BNK Forge

1. Add this repository as a Module Source and sync it.
2. Add this repository as a Blueprint Source and sync it.
3. Import either:
   - `blueprints/ibm-roks-cluster-create/forge-blueprint.json`
   - `blueprints/ibm-roks-existing-cluster/forge-blueprint.json`
4. Deploy the imported blueprint into an IBM project.
5. Run BNK managed-cluster detection after apply succeeds.
