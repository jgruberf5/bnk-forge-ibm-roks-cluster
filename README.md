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

## Variable Sources

This section traces every module input back to its source (a blueprint
variable, an upstream module's output, a hardcoded literal in the
blueprint, or the module's own `variables.tf` default) so anyone
reviewing a deploy can see exactly where each value comes from.

Source-kind shorthand used in the tables:

- **blueprint-var** — value comes from a top-level blueprint variable
  the user can override at deploy time. The default shown is the
  blueprint variable's default.
- **upstream-output** — value is auto-wired by the BNK Forge
  dependency graph from a previous module's `outputs.tf`. Not shown in
  the deploy form.
- **hardcoded-literal** — the blueprint passes a fixed value; users
  cannot change it without editing the blueprint.
- **module-default** — the blueprint does not pass this variable;
  the module falls back to the default declared in its own
  `variables.tf`.

Sensitive variables are marked **🔒** next to their name.

### Blueprint: `ibm-roks-cluster-create`

#### Module dependency tree

```text
cluster-create  (modules/roks-cluster-create)
└── cert-manager  (modules/roks-cluster-install-cert-manager)
    └── flo  (modules/roks-cluster-install-flo)
        └── cneinstance  (modules/roks-cluster-cneinstall)
            └── license  (modules/roks-cluster-license)
```

#### Module: `cluster-create`

| Module variable | Source kind | Source detail | Default |
| --------------- | ----------- | ------------- | ------- |
| `ibmcloud_api_key` 🔒 | blueprint-var | `ibmcloud_api_key` (required) | _user-provided_ |
| `ibmcloud_cluster_region` | blueprint-var | `ibmcloud_cluster_region` (required) | _user-provided_ |
| `ibmcloud_resource_group` | blueprint-var | `ibmcloud_resource_group` | `"default"` |
| `roks_cluster_name` | blueprint-var | `roks_cluster_name` (required) | _user-provided_ |
| `ibmcloud_cos_instance_name` | blueprint-var | `ibmcloud_cos_instance_name` | `"bnk-orchestration"` |
| `workers_per_zone` | blueprint-var | `workers_per_zone` | `2` |
| `openshift_cluster_version` | blueprint-var | `openshift_cluster_version` | `"4.18"` |
| `min_worker_vcpu_count` | blueprint-var | `min_worker_vcpu_count` | `16` |
| `min_worker_memory_gb` | blueprint-var | `min_worker_memory_gb` | `64` |
| `worker_flavor` | blueprint-var | `worker_flavor` | `""` |
| `cluster_vpc_name` | blueprint-var | `cluster_vpc_name` | `""` |
| `cluster_vpc_cidr` | blueprint-var | `cluster_vpc_cidr` | `"10.0.0.0/16"` |
| `zones` | blueprint-var | `zones` | `[]` |

Outputs (consumed downstream): `cluster_id`, `cluster_name`, `openshift_cluster_public_endpoint`, `region`, `cos_instance_name`, `kubeconfig` 🔒

#### Module: `cert-manager`

| Module variable | Source kind | Source detail | Default |
| --------------- | ----------- | ------------- | ------- |
| `ibmcloud_api_key` 🔒 | blueprint-var | `ibmcloud_api_key` | _user-provided_ |
| `ibmcloud_cluster_region` | blueprint-var | `ibmcloud_cluster_region` | _user-provided_ |
| `ibmcloud_resource_group` | blueprint-var | `ibmcloud_resource_group` | `"default"` |
| `roks_cluster_name_or_id` | blueprint-var | `roks_cluster_name` | _user-provided_ |
| `namespace` | blueprint-var | `cert_manager_namespace` | `"cert-manager"` |
| `chart_version` | blueprint-var | `cert_manager_version` | `"v1.17.3"` |
| `chart_repository` | module-default | `variables.tf` default | `"https://charts.jetstack.io"` |
| `wait_for_deployment` | module-default | `variables.tf` default | `true` |
| `timeout` | module-default | `variables.tf` default | `300` |
| `post_deployment_delay` | module-default | `variables.tf` default | `30` |

Outputs: `namespace`, `crd_ready`, `helm_release_name`, `helm_release_version`.

#### Module: `flo`

| Module variable | Source kind | Source detail | Default |
| --------------- | ----------- | ------------- | ------- |
| `ibmcloud_api_key` 🔒 | blueprint-var | `ibmcloud_api_key` | _user-provided_ |
| `ibmcloud_cluster_region` | blueprint-var | `ibmcloud_cluster_region` | _user-provided_ |
| `ibmcloud_resource_group` | blueprint-var | `ibmcloud_resource_group` | `"default"` |
| `roks_cluster_name_or_id` | blueprint-var | `roks_cluster_name` | _user-provided_ |
| `cert_manager_crd_ready` | hardcoded-literal | `true` | `true` |
| `cert_manager_namespace` | blueprint-var | `cert_manager_namespace` | `"cert-manager"` |
| `f5_bigip_k8s_manifest_version` | blueprint-var | `f5_bigip_k8s_manifest_version` | `"2.3.0-3.2598.3-0.0.170"` |
| `flo_namespace` | blueprint-var | `flo_namespace` | `"f5-bnk"` |
| `flo_utils_namespace` | blueprint-var | `flo_utils_namespace` | `"f5-utils"` |
| `ibmcloud_cos_instance_name` | blueprint-var | `ibmcloud_cos_instance_name` | `"bnk-orchestration"` |
| `ibmcloud_resources_cos_bucket` | blueprint-var | `ibmcloud_resources_cos_bucket` | `"bnk-schematics-resources"` |
| `ibmcloud_cos_bucket_region` | blueprint-var | `ibmcloud_cos_bucket_region` | `"us-south"` |
| `bigip_url` | blueprint-var | `bigip_url` | `""` |
| `bigip_username` | blueprint-var | `bigip_username` | `"admin"` |
| `bigip_password` 🔒 | blueprint-var | `bigip_password` | `""` |
| `far_repo_url` | blueprint-var | `far_repo_url` | `"repo.f5.com"` |
| `f5_cne_far_auth_file` | blueprint-var | `f5_cne_far_auth_file` | `"f5-far-auth-key.tgz"` |
| `nad_cni_type` | blueprint-var | `nad_cni_type` | `"ipvlan"` |
| `nad_interface_name` | blueprint-var | `nad_interface_name` | `"ens3"` |
| `nad_ipvlan_mode` | blueprint-var | `nad_ipvlan_mode` | `"l2"` |
| `use_cos_bucket` | module-default | `variables.tf` default | `true` |
| `f5_cne_subscription_jwt_file` | module-default | `variables.tf` default | `"trial.jwt"` |

Outputs: `flo_release_name`, `flo_namespace`, `flo_utils_namespace`, `flo_trusted_profile_id`, `flo_cluster_issuer_name`, `cneinstance_network_attachments`.

#### Module: `cneinstance`

| Module variable | Source kind | Source detail | Default |
| --------------- | ----------- | ------------- | ------- |
| `ibmcloud_api_key` 🔒 | blueprint-var | `ibmcloud_api_key` | _user-provided_ |
| `ibmcloud_cluster_region` | blueprint-var | `ibmcloud_cluster_region` | _user-provided_ |
| `ibmcloud_resource_group` | blueprint-var | `ibmcloud_resource_group` | `"default"` |
| `roks_cluster_name_or_id` | blueprint-var | `roks_cluster_name` | _user-provided_ |
| `f5_bigip_k8s_manifest_version` | blueprint-var | `f5_bigip_k8s_manifest_version` | `"2.3.0-3.2598.3-0.0.170"` |
| `flo_namespace` | blueprint-var | `flo_namespace` | `"f5-bnk"` |
| `flo_utils_namespace` | blueprint-var | `flo_utils_namespace` | `"f5-utils"` |
| `far_repo_url` | blueprint-var | `far_repo_url` | `"repo.f5.com"` |
| `cneinstance_deployment_size` | blueprint-var | `cneinstance_deployment_size` | `"Small"` |
| `cneinstance_gslb_datacenter_name` | blueprint-var | `cneinstance_gslb_datacenter_name` | `""` |
| `cneinstance_network_attachments` | blueprint-var | `cneinstance_network_attachments` | `["ens3-ipvlan-l2", "macvlan-conf"]` |
| `flo_trusted_profile_id` | upstream-output | `flo.flo_trusted_profile_id` | _auto-wired at apply_ |
| `flo_cluster_issuer_name` | upstream-output | `flo.flo_cluster_issuer_name` | _auto-wired at apply_ |
| `cneinstance_gateway_api` | module-default | `variables.tf` default | `true` |
| `cneinstance_whole_cluster` | module-default | `variables.tf` default | `true` |
| `cneinstance_logging_subsystem` | module-default | `variables.tf` default | `true` |
| `cneinstance_metric_subsystem` | module-default | `variables.tf` default | `true` |
| `cneinstance_dynamic_routing` | module-default | `variables.tf` default | `false` |
| `cneinstance_firewall_acl` | module-default | `variables.tf` default | `true` |
| `cneinstance_pseudocni` | module-default | `variables.tf` default | `true` |
| `cneinstance_env_discovery` | module-default | `variables.tf` default | `false` |
| `cneinstance_cloud_env` | module-default | `variables.tf` default | `true` |

Outputs: `cneinstance_id`, `cneinstance_namespace`, `cneinstance_pod_deployment_status`.

#### Module: `license`

| Module variable | Source kind | Source detail | Default |
| --------------- | ----------- | ------------- | ------- |
| `ibmcloud_api_key` 🔒 | blueprint-var | `ibmcloud_api_key` | _user-provided_ |
| `ibmcloud_cluster_region` | blueprint-var | `ibmcloud_cluster_region` | _user-provided_ |
| `ibmcloud_resource_group` | blueprint-var | `ibmcloud_resource_group` | `"default"` |
| `roks_cluster_name_or_id` | blueprint-var | `roks_cluster_name` | _user-provided_ |
| `use_cos_bucket` | hardcoded-literal | `true` | `true` |
| `ibmcloud_cos_instance_name` | blueprint-var | `ibmcloud_cos_instance_name` | `"bnk-orchestration"` |
| `ibmcloud_resources_cos_bucket` | blueprint-var | `ibmcloud_resources_cos_bucket` | `"bnk-schematics-resources"` |
| `ibmcloud_cos_bucket_region` | blueprint-var | `ibmcloud_cos_bucket_region` | `"us-south"` |
| `f5_cne_subscription_jwt_file` | blueprint-var | `f5_cne_subscription_jwt_file` | `"trial.jwt"` |
| `license_mode` | blueprint-var | `license_mode` | `"connected"` |
| `flo_utils_namespace` | blueprint-var | `flo_utils_namespace` | `"f5-utils"` |
| `jwt_token` | module-default | `variables.tf` default | `""` |

Outputs: `license_id`, `license_namespace`.

### Blueprint: `ibm-roks-existing-cluster`

The existing-cluster blueprint reuses the same downstream chain
(cert-manager → flo → cneinstance → license); the only difference is
that it starts with `cluster-register` instead of `cluster-create`.
The variable sources for cert-manager, flo, cneinstance, and license
are identical to the cluster-create blueprint above and are not
duplicated here.

#### Module dependency tree

```text
cluster-register  (modules/roks-cluster-register)
└── cert-manager  (modules/roks-cluster-install-cert-manager)
    └── flo  (modules/roks-cluster-install-flo)
        └── cneinstance  (modules/roks-cluster-cneinstall)
            └── license  (modules/roks-cluster-license)
```

#### Module: `cluster-register`

| Module variable | Source kind | Source detail | Default |
| --------------- | ----------- | ------------- | ------- |
| `ibmcloud_api_key` 🔒 | blueprint-var | `ibmcloud_api_key` (required) | _user-provided_ |
| `ibmcloud_cluster_region` | blueprint-var | `ibmcloud_cluster_region` (required) | _user-provided_ |
| `ibmcloud_resource_group` | blueprint-var | `ibmcloud_resource_group` | `"default"` |
| `roks_cluster_name_or_id` | blueprint-var | `roks_cluster_name_or_id` (required) | _user-provided_ |

Outputs (consumed downstream): `cluster_id`, `cluster_name`, `openshift_cluster_public_endpoint`, `region`, `kubeconfig` 🔒

### Findings

- **No dead variables.** Every blueprint input is wired into at least
  one module in both blueprints.
- **Two upstream-output auto-wires** in both blueprints: `cneinstance`
  receives `flo_trusted_profile_id` and `flo_cluster_issuer_name` from
  the `flo` module. These are not shown in the deploy form.
- **Two hardcoded literals** in both blueprints: `cert_manager_crd_ready`
  (passed `true` to flo) and `use_cos_bucket` (passed `true` to
  license). Override these by editing the blueprint, not by adjusting
  blueprint variables.
- **Sensitive inputs:** `ibmcloud_api_key` (always required) and
  `bigip_password` (optional, defaults empty). Both are stored
  encrypted by BNK Forge.
- **CNEInstance feature flags are intentionally not exposed.** The
  eleven `cneinstance_*` flags (gateway_api, whole_cluster, logging,
  metric, dynamic_routing, firewall_acl, pseudocni, env_discovery,
  cloud_env, etc.) all use the module's defaults. Surface them as
  blueprint variables only if a deployment needs to flip them.

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
