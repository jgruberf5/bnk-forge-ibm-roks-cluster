# BNK Forge IBM ROKS Cluster

Forge-ready IBM ROKS content covering the full BNK install on top of an
IBM Red Hat OpenShift on IBM Cloud cluster:

1. **Get a cluster** — either provision one or reference an existing one.
2. **Install cert-manager.**
3. **Install the F5 Lifecycle Operator (FLO).**
4. **Deploy a CNEInstance.**
5. **Apply the BNK License.**

Each step is its own Forge-ready module; two blueprints chain them
together end-to-end.

## Modules

| Module path | Purpose |
| ----------- | ------- |
| `modules/roks-cluster-create` | Create an IBM ROKS cluster using an existing IBM COS instance for the OpenShift registry. Emits the outputs BNK Forge needs to register the cluster, plus the kubeconfig. |
| `modules/roks-cluster-register` | Resolve an existing IBM ROKS cluster by name or ID and emit the same registration outputs + kubeconfig. |
| `modules/roks-cluster-install-cert-manager` | Install cert-manager (Helm chart, `installCRDs=true`, `ServerSideApply` feature gate). |
| `modules/roks-cluster-install-flo` | Install F5 Lifecycle Operator: Helm release, IBM IAM trusted profile, BIG-IP CIS controller config, NAD setup. Vendored FLO submodule under `modules/flo/` mirrors the upstream `ibmcloud_schematics_bigip_next_for_kubernetes_2_3_flo` reference. |
| `modules/roks-cluster-cneinstall` | Deploy a `CNEInstance` custom resource. Vendored CNEInstance submodule under `modules/cneinstance/` mirrors `ibmcloud_schematics_bigip_next_for_kubernetes_2_3_cneinstance`. |
| `modules/roks-cluster-license` | Apply the BNK License CR, fetching the F5 subscription JWT from the configured IBM COS bucket. Vendored license submodule under `modules/license/` mirrors `ibmcloud_schematics_bigip_next_for_kubernetes_2_3_license`. |

## Blueprints

| Blueprint | Module chain |
| --------- | ------------ |
| `blueprints/ibm-roks-cluster-create` | `cluster-create` → `cert-manager` → `flo` → `cneinstance` → `license` |
| `blueprints/ibm-roks-existing-cluster` | `cluster-register` → `cert-manager` → `flo` → `cneinstance` → `license` |

Both blueprints set explicit `order` on every input so the deploy form
follows the deployment flow: IBM credentials → cluster identity →
cert-manager → FLO (incl. BIG-IP CIS, COS bucket, NAD) → CNEInstance →
License.

## IBM Cloud Credential Template compatibility

Every module and both blueprints intentionally use the BNK Forge IBM
credential-template variable names:

- `ibmcloud_api_key`
- `ibmcloud_cluster_region`
- `ibmcloud_resource_group`

That lets BNK Forge prefill these values from the selected IBM Cloud
Credential Template in both flows:

- **Add Module to Project**
- **Imported Blueprint deployment**

## BNK registration outputs

The `roks-cluster-create` and `roks-cluster-register` modules emit the
fields BNK Forge needs to auto-register the cluster in the Kubernetes
inventory:

- `cluster_name`
- `cluster_id`
- `openshift_cluster_public_endpoint`
- `region`
- `kubeconfig` (base64-encoded; bnk-forge adopts it on first scan)

After apply succeeds, BNK Forge auto-registers the cluster — no manual
step required.

## Import into BNK Forge

1. Add this repository as both a **Module Source** and a **Blueprint
   Source** and sync it. (BNK Forge will auto-detect the dual nature.)
2. Import the blueprint that fits your scenario:
   - `ibm-roks-cluster-create` for new clusters.
   - `ibm-roks-existing-cluster` for clusters that already exist.
3. Deploy the imported blueprint into an IBM project that is linked to
   an IBM Cloud Credential Template.
4. After apply succeeds, BNK Forge will register the cluster on its
   Kubernetes page automatically.

## Repo layout

```text
bnk-forge-ibm-roks-cluster/
  modules/
    roks-cluster-create/                       # bnkforge.pack.json, main.tf, variables.tf, outputs.tf, README.md
    roks-cluster-register/
    roks-cluster-install-cert-manager/
    roks-cluster-install-flo/
      modules/flo/                             # vendored from upstream FLO reference
    roks-cluster-cneinstall/
      modules/cneinstance/                     # vendored from upstream CNEInstance reference
    roks-cluster-license/
      modules/license/                         # vendored from upstream license reference
  blueprints/
    ibm-roks-cluster-create/forge-blueprint.json
    ibm-roks-existing-cluster/forge-blueprint.json
```
