# IBM ROKS BNK License Module

## Purpose

Deploys the BIG-IP Next License custom resource onto an existing IBM ROKS cluster after BNK platform components are already installed.

This wrapper targets the upstream license module from:

- `f5devcentral/ibmcloud_schematics_bigip_next_for_kubernetes_2_3_license//modules/license`

## Engine

- Engine: `opentofu`
- Module root: `tofu/`

## Inputs

The primary operator-facing inputs are:

- IBM Cloud API key
- region
- resource group
- existing ROKS cluster name or ID
- FLO utilities namespace
- license mode
- either a direct JWT token or IBM COS settings to fetch the JWT token

## BNK Input Mapping

The wrapper keeps BNK-friendly IBM and FLO input names and passes them to the upstream module contract:

- `roks_cluster_name_or_id` -> cluster discovery data sources
- `flo_utils_namespace` -> `utils_namespace`
- `jwt_token` -> `jwt_token`
- `use_cos_bucket` -> `use_cos_bucket`
- `f5_cne_subscription_jwt_file` -> `f5_cne_subscription_jwt_file`

## Outputs

The outputs expose the created License custom resource name and namespace so BNK operators can verify the in-cluster license registration step.
