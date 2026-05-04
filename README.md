# BNK Forge IBM ROKS Cluster 4

Forge-ready IBM ROKS cluster content focused on a single outcome: provision an IBM ROKS cluster together with the registry COS instance and transit gateway required for the cluster foundation.

This repository contains:

- one reusable OpenTofu deployment-pack module under `modules/cluster`
- one imported blueprint manifest under `blueprints/ibm-roks-cluster`

## Design Goals

- only ask operators for the minimum cluster inputs
- derive supporting resource names from the requested ROKS cluster name
- keep the module recognizable as a ROKS cluster so BNK can register it in the Operate Kubernetes inventory after deployment

## Layout

```text
bnk-forge-ibm-roks-cluster-4/
  modules/
    cluster/
      bnkforge.pack.json
      README.md
      tofu/
        main.tf
        variables.tf
        outputs.tf
  blueprints/
    ibm-roks-cluster/
      forge-blueprint.json
      README.md
  examples/
    project.auto.tfvars.example
```

## Required Inputs

- `ibmcloud_api_key`
- `ibmcloud_cluster_region`
- `ibmcloud_resource_group` (defaults to `default`)
- `roks_cluster_name`
- `workers_per_zone`
- `min_worker_vcpu_count` (defaults to `16`)
- `min_worker_memory_gb` (defaults to `64`)

The cluster COS instance name and transit gateway name are derived from `roks_cluster_name`.

In Forge, the IBM Cloud API key, region, and resource group can still be prefilled from a Cloud Credential Template or project defaults even though the deployment-pack manifest models them as user-supplied values.

With the accompanying BNK-Forge credential-template update, IBM credential templates now carry `ibmcloud_resource_group` and can automatically provide that value to stack deployments when the user leaves the blueprint input at its default.

## Import into BNK Forge

1. Add this repository as a Module Source and sync it.
2. Add this repository as a Blueprint Source and import `blueprints/ibm-roks-cluster/forge-blueprint.json`.
3. Deploy the imported blueprint into an IBM project.
4. After apply succeeds, run the managed-cluster detection flow in BNK if needed. The module is cataloged as `roks` and emits the ROKS outputs BNK expects for inventory registration.
