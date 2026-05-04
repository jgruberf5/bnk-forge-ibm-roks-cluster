# IBM ROKS BNK CNEInstance Single NIC Module

## Purpose

Deploys the BIG-IP Next CNEInstance component onto an existing IBM ROKS cluster after FLO has already been installed.

This wrapper targets the upstream CNEInstance module from:

- `f5devcentral/ibmcloud_schematics_bigip_next_for_kubernetes_2_3_cneinstance//modules/cneinstance`

## Engine

- Engine: `opentofu`
- Module root: `tofu/`

## Inputs

The primary operator-facing inputs are:

- IBM Cloud API key
- region
- resource group
- existing ROKS cluster name or ID
- FLO namespace and utility namespace
- FLO manifest version, trusted profile ID, and cluster issuer name
- optional CNEInstance deployment size and GSLB datacenter name
- network attachment names for the single-NIC topology

## BNK Input Mapping

The wrapper keeps BNK-friendly IBM and FLO input names and passes them to the upstream module contract:

- `roks_cluster_name_or_id` -> cluster discovery data sources
- `flo_namespace` -> `flo_namespace`
- `flo_utils_namespace` -> `utils_namespace`
- `flo_trusted_profile_id` -> `cneinstance_ibm_trusted_profile_id`
- `flo_cluster_issuer_name` -> `cluster_issuer_name`
- `cneinstance_network_attachments` -> `cneinstance_network_attachments`

## Outputs

The outputs expose the created CNEInstance resource, namespace, SCC policy summary, and pod readiness details so BNK operators can verify the in-cluster deployment.
