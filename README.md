# BNK Forge IBM ROKS Cluster 4

Forge-ready IBM ROKS cluster content focused on a single outcome: provision IBM Cloud ROKS cluster and attached Transit Gateway.

This repository contains:

- one reusable OpenTofu cluster deployment-pack module under `modules/cluster`
- one reusable OpenTofu FLO deployment-pack module under `modules/flo`
- one reusable OpenTofu CNEInstance deployment-pack module under `modules/cneinstance`
- one reusable OpenTofu License deployment-pack module under `modules/license`
- one imported blueprint manifest under `blueprints/ibm-roks-cluster`

The cluster wrapper targets the upstream module at `f5devcentral/ibmcloud_schematics_bigip_next_for_kubernetes_roks_cluster_4//modules/cluster` while preserving BNK-friendly variable names.

The FLO wrapper targets the upstream module at `f5devcentral/ibmcloud_schematics_bigip_next_for_kubernetes_2_3_flo//modules/flo` so BNK can install platform components onto an existing ROKS cluster.

The CNEInstance wrapper targets the upstream module at `f5devcentral/ibmcloud_schematics_bigip_next_for_kubernetes_2_3_cneinstance//modules/cneinstance` for existing-cluster single-NIC deployments that build on top of FLO.

The License wrapper targets the upstream module at `f5devcentral/ibmcloud_schematics_bigip_next_for_kubernetes_2_3_license//modules/license` for existing-cluster license registration after BNK platform components are available.

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
    flo/
      bnkforge.pack.json
      README.md
      tofu/
        main.tf
        variables.tf
        outputs.tf
    cneinstance/
      bnkforge.pack.json
      README.md
      tofu/
        main.tf
        variables.tf
        outputs.tf
    license/
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
4. After apply succeeds, run the managed-cluster detection flow in BNK if needed. The module emits the ROKS outputs BNK expects for inventory registration.

## Available Modules

- `modules/cluster` exposes `ibm_roks_single_nic` for provisioning a new IBM ROKS cluster plus the registry COS instance and transit gateway.
- `modules/flo` exposes `ibm_roks_bnk_flo` for installing BNK onto an existing IBM ROKS cluster.
- `modules/cneinstance` exposes `ibm_roks_bnk_cneinstance_single_nic` for installing the BIG-IP Next CNEInstance component onto an existing IBM ROKS cluster after FLO is available.
- `modules/license` exposes `ibm_roks_bnk_license` for installing the BIG-IP Next License custom resource onto an existing IBM ROKS cluster after CNEInstance is available.
