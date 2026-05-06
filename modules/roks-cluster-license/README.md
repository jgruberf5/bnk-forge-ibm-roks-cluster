# roks-cluster-license

Applies a **BNK License** custom resource into an existing IBM ROKS
cluster. The license sub-module under `modules/license/` is vendored
verbatim from
[`ibmcloud_schematics_bigip_next_for_kubernetes_2_3_license`](../../../ibmcloud_schematics_bigip_next_for_kubernetes_2_3_license/modules/license/);
this top-level wrapper supplies the IBM Cloud + Kubernetes provider
plumbing needed to drive it from a bnk-forge project.

## What it does

1. Resolves the IBM Cloud resource group and looks up the target ROKS
   cluster credentials dynamically via `ibm_container_cluster_config`.
2. Wires the `kubernetes` and `http` providers using the live cluster
   config and forwards them to the vendored license sub-module.
3. Fetches the F5 subscription JWT from the configured IBM COS bucket
   (when `use_cos_bucket = true`) or accepts one passed directly.
4. Applies the License custom resource into the F5 utils namespace
   (typically `f5-utils`), in the operation mode requested
   (`connected` / `disconnected`).

## Credentials

IBM Cloud credentials (`ibmcloud_api_key`, `ibmcloud_resource_group`,
`ibmcloud_cluster_region`) are inherited from the bnk-forge project's IBM
Cloud Credential Template — same pattern as the other
`ibm_roks_cluster_*` modules in this repo.

## Dependencies

`ibm_roks_cluster_cneinstall` must be applied first so the License CRD
(installed alongside the BNK platform) is available before the License
CR is created.

## Inputs

See `bnkforge.pack.json` for the full list. Most-used:

| Name | Default | Description |
| ---- | ------- | ----------- |
| `ibmcloud_api_key` | — | From the IBM Cloud Credential Template. |
| `ibmcloud_cluster_region` | — | Region of the target cluster. |
| `roks_cluster_name_or_id` | — | Existing ROKS cluster name or ID. |
| `ibmcloud_cos_instance_name` | `bnk-orchestration` | COS instance holding the JWT. |
| `ibmcloud_resources_cos_bucket` | `bnk-schematics-resources` | COS bucket name. |
| `f5_cne_subscription_jwt_file` | `trial.jwt` | JWT object key. |
| `license_mode` | `connected` | `connected` or `disconnected`. |
| `flo_utils_namespace` | `f5-utils` | Where the License CR is created. |

## Outputs

| Name | Description |
| ---- | ----------- |
| `license_id` | License resource name. |
| `license_namespace` | Namespace where the License CR was applied. |
| `cluster_id` | Cluster ID passthrough. |
