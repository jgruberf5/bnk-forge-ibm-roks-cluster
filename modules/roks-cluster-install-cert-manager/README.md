# roks-cluster-install-cert-manager

Installs [cert-manager](https://cert-manager.io/) into an existing IBM ROKS
(Red Hat OpenShift on IBM Cloud) cluster.

## What it does

1. Resolves the IBM Cloud resource group and looks up the target ROKS cluster.
2. Pulls cluster credentials dynamically via `ibm_container_cluster_config` —
   no kubeconfig on disk required.
3. Wires `kubernetes` and `helm` providers using the live cluster config.
4. Creates the `cert-manager` namespace.
5. Deploys the cert-manager Helm chart with `installCRDs=true` and the
   `ServerSideApply=true` feature gate.
6. Sleeps briefly so cert-manager CRDs (`ClusterIssuer`, `Certificate`, …)
   are fully registered before any downstream module references them.

## Credentials

IBM Cloud credentials (`ibmcloud_api_key`, `ibmcloud_resource_group`,
`ibmcloud_cluster_region`) are inherited from the bnk-forge project's IBM
Cloud Credential Template, the same way the
`ibm_roks_cluster_register_existing` module receives them.

## Inputs

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `ibmcloud_api_key` | string (sensitive) | — | IBM Cloud API key. |
| `ibmcloud_cluster_region` | string | — | IBM Cloud region of the cluster. |
| `roks_cluster_name_or_id` | string | — | Existing ROKS cluster name or ID. |
| `ibmcloud_resource_group` | string | `default` | Resource group for cluster discovery. |
| `namespace` | string | `cert-manager` | Namespace for cert-manager. |
| `chart_version` | string | `v1.17.3` | cert-manager Helm chart version. |
| `chart_repository` | string | `https://charts.jetstack.io` | Helm chart repository URL. |
| `wait_for_deployment` | bool | `true` | Wait for cert-manager pods to be ready. |
| `timeout` | number | `300` | Helm release timeout (seconds). |
| `post_deployment_delay` | number | `30` | Delay (seconds) after release for CRD registration. |

## Outputs

| Name | Description |
| ---- | ----------- |
| `namespace` | Namespace where cert-manager is deployed. |
| `helm_release_name` | Name of the cert-manager Helm release. |
| `helm_release_version` | Installed cert-manager Helm chart version. |
| `crd_ready` | `true` once the post-deployment delay has elapsed. |
| `cluster_id` / `cluster_name` | Passthrough for downstream wiring. |
