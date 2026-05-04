# IBM ROKS Cluster Module

## Purpose

Provisions an IBM ROKS cluster together with a registry COS instance and transit gateway, while keeping the operator input surface minimal.

This wrapper targets the upstream cluster-only module from:

- `f5devcentral/ibmcloud_schematics_bigip_next_for_kubernetes_roks_cluster_4//modules/cluster`

## Engine

- Engine: `opentofu`
- Module root: `tofu/`

## Inputs

The primary operator-facing inputs are:

- IBM Cloud API key
- region
- resource group
- ROKS cluster name
- worker count per zone
- worker sizing thresholds

The module derives:

- `cos_instance_name = "${roks_cluster_name}-registry-cos"`
- `transit_gateway_name = "${roks_cluster_name}-tgw"`

## BNK Input Mapping

The wrapper keeps BNK-friendly input names and maps them to the upstream module contract:

- `ibmcloud_cluster_region` -> `cluster_region`
- `ibmcloud_resource_group` -> `resource_group`
- `roks_cluster_name` -> `openshift_cluster_name`

The worker sizing and OpenShift version inputs are passed through directly.

## Outputs

The outputs include cluster name, ID, public endpoint, CRN, and region so BNK can register the deployed cluster into the Kubernetes inventory.
