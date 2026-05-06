# roks-cluster-install-flo

Installs the **F5 Lifecycle Operator (FLO)** into an existing IBM ROKS
cluster. The FLO sub-module under `modules/flo/` is vendored verbatim from
[`ibmcloud_schematics_bigip_next_for_kubernetes_2_3_flo`](../../../ibmcloud_schematics_bigip_next_for_kubernetes_2_3_flo/modules/flo/);
this top-level wrapper supplies the IBM Cloud + Kubernetes provider plumbing
needed to drive it from a bnk-forge project.

## What it does

1. Resolves the IBM Cloud resource group, looks up the target ROKS cluster,
   and discovers the cluster's VPC.
2. Pulls cluster credentials dynamically via `ibm_container_cluster_config`
   — no kubeconfig on disk required.
3. Wires `kubernetes`, `helm`, and `ibm` providers using the live cluster
   config and forwards them to the vendored FLO sub-module.
4. Applies the FLO sub-module, which installs the f5-lifecycle-operator
   Helm release, the f5-utils namespace, ClusterIssuer/Certificate
   resources, NetworkAttachmentDefinitions, and the IBM IAM trusted
   profile binding for the CNE controller service account.

## Credentials

IBM Cloud credentials (`ibmcloud_api_key`, `ibmcloud_resource_group`,
`ibmcloud_cluster_region`) are inherited from the bnk-forge project's IBM
Cloud Credential Template — same pattern as
`ibm_roks_cluster_register_existing` and `ibm_roks_cluster_install_cert_manager`.

## Dependencies

`ibm_roks_cluster_install_cert_manager` must be applied first — FLO's
ClusterIssuer/Certificate resources require cert-manager CRDs to be
present.

## Inputs

See `bnkforge.pack.json` for the full input list. The ones you'll
typically care about per-deployment:

| Name | Default | Description |
| ---- | ------- | ----------- |
| `ibmcloud_api_key` | — | From the IBM Cloud Credential Template. |
| `ibmcloud_cluster_region` | — | Region of the target cluster. |
| `roks_cluster_name_or_id` | — | Existing ROKS cluster name or ID. |
| `f5_bigip_k8s_manifest_version` | `2.3.0-bnpp-ehf-2-3.2598.3-0.0.17` | Drives FLO/CIS chart versions. |
| `bigip_url` / `bigip_username` / `bigip_password` | — | BIG-IP CIS controller login. |
| `flo_namespace` | `f5-bnk` | Where FLO lives. |
| `cert_manager_namespace` | `cert-manager` | Must match the cert-manager install. |
| `nad_cni_type` / `nad_interface_name` / `nad_ipvlan_mode` | `ipvlan` / `ens3` / `l2` | NAD configuration. |

## Outputs

| Name | Description |
| ---- | ----------- |
| `flo_release_name` / `flo_namespace` / `flo_utils_namespace` | Helm release + namespaces. |
| `flo_version` / `flo_extracted_flo_version` | Installed versions. |
| `flo_trusted_profile_id` | IBM IAM Trusted Profile bound to the CNE service account. |
| `flo_pod_deployment_status` | FLO pod readiness. |
| `flo_cluster_issuer_name` | mTLS issuer name. |
| `cneinstance_network_attachments` | NAD configuration applied to CNEInstance. |
| `cluster_id` / `cluster_name` | Passthrough for downstream wiring. |
