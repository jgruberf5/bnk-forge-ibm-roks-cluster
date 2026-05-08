terraform {
  required_version = ">= 1.0"

  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.60.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.0"
    }
  }
}

# IBM Cloud provider — credentials inherited from the project's IBM Cloud
# Credential Template (same pattern as roks-cluster-register).
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.ibmcloud_cluster_region
}

data "ibm_resource_groups" "all_resource_groups" {}

data "ibm_resource_group" "resource_group" {
  name = var.ibmcloud_resource_group != "" ? var.ibmcloud_resource_group : [
    for rg in data.ibm_resource_groups.all_resource_groups.resource_groups :
    rg.name if rg.is_default == true
  ][0]
}

# Look up the existing ROKS cluster — needed for trusted-profile binding
# (CRN, name) and as the entry point for VPC discovery.
data "ibm_container_vpc_cluster" "cluster" {
  name              = var.roks_cluster_name_or_id
  resource_group_id = data.ibm_resource_group.resource_group.id
}

# Resolve a subnet from the first worker pool zone to learn the VPC.
data "ibm_is_subnet" "cluster_subnet" {
  identifier = data.ibm_container_vpc_cluster.cluster.worker_pools[0].zones[0].subnets[0].id
}

data "ibm_is_vpc" "cluster_vpc" {
  identifier = data.ibm_is_subnet.cluster_subnet.vpc
}

# Pull cluster credentials dynamically — no kubeconfig on disk required.
data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id = var.roks_cluster_name_or_id
  region          = var.ibmcloud_cluster_region
}

# Kubernetes + Helm providers wired to the live cluster config.
provider "kubernetes" {
  host                   = try(data.ibm_container_cluster_config.cluster_config.host, "")
  token                  = try(data.ibm_container_cluster_config.cluster_config.token, "")
  cluster_ca_certificate = try(base64decode(data.ibm_container_cluster_config.cluster_config.ca_certificate), null)
}

provider "helm" {
  # Helm provider v3+ requires `kubernetes = {...}` (argument with equals),
  # not the legacy v2 `kubernetes {...}` block syntax.
  kubernetes = {
    host                   = try(data.ibm_container_cluster_config.cluster_config.host, "")
    token                  = try(data.ibm_container_cluster_config.cluster_config.token, "")
    cluster_ca_certificate = try(base64decode(data.ibm_container_cluster_config.cluster_config.ca_certificate), null)
  }
}

# F5 Lifecycle Operator — vendored copy of the FLO module from
# ibmcloud_schematics_bigip_next_for_kubernetes_2_3_flo.
module "flo" {
  source = "./modules/flo"

  depends_on = [data.ibm_container_cluster_config.cluster_config]

  providers = {
    kubernetes = kubernetes
    helm       = helm
    ibm        = ibm
  }

  enabled = true

  # Caller asserts cert-manager has already been applied on the cluster.
  # In the blueprint, this is wired to the cert-manager module's crd_ready output.
  cert_manager_crd_ready = var.cert_manager_crd_ready

  far_repo_url = var.far_repo_url

  # COS Bucket Configuration
  use_cos_bucket                = var.use_cos_bucket
  ibmcloud_api_key              = var.ibmcloud_api_key
  ibmcloud_cos_bucket_region    = var.ibmcloud_cos_bucket_region
  ibmcloud_resource_group       = var.ibmcloud_resource_group
  ibmcloud_cos_instance_name    = var.ibmcloud_cos_instance_name
  ibmcloud_resources_cos_bucket = var.ibmcloud_resources_cos_bucket
  f5_cne_far_auth_file          = var.f5_cne_far_auth_file
  f5_cne_subscription_jwt_file  = var.f5_cne_subscription_jwt_file

  # FLO Configuration
  f5_bigip_k8s_manifest_version = var.f5_bigip_k8s_manifest_version
  flo_namespace                 = var.flo_namespace
  utils_namespace               = var.flo_utils_namespace
  kube_host                     = data.ibm_container_cluster_config.cluster_config.host
  kube_token                    = data.ibm_container_cluster_config.cluster_config.token

  # BIG-IP CIS Configuration
  bigip_username = var.bigip_username
  bigip_password = var.bigip_password
  bigip_url      = var.bigip_url

  # Cluster identity — learned from the cluster data source
  openshift_cluster_name = data.ibm_container_vpc_cluster.cluster.name
  openshift_cluster_crn  = data.ibm_container_vpc_cluster.cluster.crn
  cluster_vpc_id         = data.ibm_is_vpc.cluster_vpc.id

  # NAD Configuration
  nad_cni_type       = var.nad_cni_type
  nad_interface_name = var.nad_interface_name
  nad_ipvlan_mode    = var.nad_ipvlan_mode

  # Certificate Manager
  cert_manager_namespace = var.cert_manager_namespace
}
