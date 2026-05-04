# IBM ROKS BNK FLO Module

## Purpose

Deploys F5 BIG-IP Next for Kubernetes onto an existing IBM ROKS cluster without creating cluster infrastructure.

This wrapper targets the upstream FLO module from:

- `f5devcentral/ibmcloud_schematics_bigip_next_for_kubernetes_2_3_flo//modules/flo`

## Engine

- Engine: `opentofu`
- Module root: `tofu/`

## Inputs

The primary operator-facing inputs are:

- IBM Cloud API key
- region
- resource group
- existing ROKS cluster name or ID
- FAR manifest version
- COS bucket settings for FAR auth and JWT retrieval
- FLO and utilities namespaces
- optional BIG-IP CIS connection values

## BNK Input Mapping

The wrapper keeps BNK-friendly IBM input names and passes them to the upstream module contract:

- `ibmcloud_cluster_region` -> `ibmcloud_cluster_region`
- `ibmcloud_resource_group` -> `ibmcloud_resource_group`
- `roks_cluster_name_or_id` -> `roks_cluster_name_or_id`
- `flo_utils_namespace` -> `flo_utils_namespace`

## Outputs

The outputs expose FLO release details, namespace names, deployment status, and trusted profile identifiers so BNK operators can verify the in-cluster install.
