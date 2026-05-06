# roks-cluster-cneinstall

Deploys a **CNEInstance** custom resource into an existing IBM ROKS cluster
once the F5 Lifecycle Operator (FLO) has been installed. The CNEInstance
sub-module under `modules/cneinstance/` is vendored verbatim from
[`ibmcloud_schematics_bigip_next_for_kubernetes_2_3_cneinstance`](../../../ibmcloud_schematics_bigip_next_for_kubernetes_2_3_cneinstance/modules/cneinstance/);
this top-level wrapper supplies the IBM Cloud + Kubernetes provider
plumbing needed to drive it from a bnk-forge project.

## What it does

1. Resolves the IBM Cloud resource group, looks up the target ROKS cluster,
   and discovers the cluster's VPC.
2. Pulls cluster credentials dynamically via `ibm_container_cluster_config`
   — no kubeconfig on disk required.
3. Wires the `kubernetes` provider to the live cluster config and forwards
   it to the vendored CNEInstance sub-module.
4. Applies the CNEInstance sub-module, which builds a `CNEInstance` CR with
   the gateway-api/logging/metrics/firewall/pseudocni/cloud-env feature set
   the reference orchestrator uses, wires it to the FLO ClusterIssuer and
   Trusted Profile, and waits for the TMM/Helm pods to become ready.

## Credentials

IBM Cloud credentials (`ibmcloud_api_key`, `ibmcloud_resource_group`,
`ibmcloud_cluster_region`) are inherited from the bnk-forge project's IBM
Cloud Credential Template — same pattern as
`ibm_roks_cluster_register_existing`,
`ibm_roks_cluster_install_cert_manager`, and
`ibm_roks_cluster_install_flo`.

## Dependencies

`ibm_roks_cluster_install_flo` must be applied first. The CNEInstance
references:

- The FLO ClusterIssuer (`flo_cluster_issuer_name`) for mTLS certs.
- The IBM IAM Trusted Profile (`flo_trusted_profile_id`) so the data plane
  can program VPC routes.

In a blueprint, wire those two inputs from the FLO module's outputs.

## Inputs

See `bnkforge.pack.json` for the full list. Most-used:

| Name | Default | Description |
| ---- | ------- | ----------- |
| `ibmcloud_api_key` | — | From the IBM Cloud Credential Template. |
| `ibmcloud_cluster_region` | — | Region of the target cluster. |
| `roks_cluster_name_or_id` | — | Existing ROKS cluster name or ID. |
| `flo_cluster_issuer_name` | `""` | Wire from FLO output. |
| `flo_trusted_profile_id` | `""` | Wire from FLO output. |
| `cneinstance_deployment_size` | `Small` | `Small` / `Medium` / `Large`. |
| `cneinstance_network_attachments` | `["ens3-ipvlan-l2", "macvlan-conf"]` | Multus NADs for TMM. |
| `cneinstance_gslb_datacenter_name` | `""` | Optional GSLB datacenter name. |

## Outputs

| Name | Description |
| ---- | ----------- |
| `cneinstance_id` | CNEInstance resource name. |
| `cneinstance_namespace` | Namespace where CNEInstance lives. |
| `cneinstance_pod_deployment_status` | TMM/Helm pod readiness. |
| `cluster_id` / `cluster_name` | Passthrough for downstream wiring. |
