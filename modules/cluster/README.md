# IBM ROKS Cluster Module

## Purpose

Provisions an IBM ROKS cluster together with a registry COS instance and transit gateway, while keeping the operator input surface minimal.

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

## Outputs

The outputs include cluster name, ID, public endpoint, CRN, and region so BNK can register the deployed cluster into the Kubernetes inventory.
