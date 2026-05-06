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
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0.0"
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

# Pull cluster credentials dynamically — no kubeconfig on disk required.
data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id = var.roks_cluster_name_or_id
  region          = var.ibmcloud_cluster_region
}

# Kubernetes provider wired to the live cluster config.
provider "kubernetes" {
  host                   = try(data.ibm_container_cluster_config.cluster_config.host, "")
  token                  = try(data.ibm_container_cluster_config.cluster_config.token, "")
  cluster_ca_certificate = try(base64decode(data.ibm_container_cluster_config.cluster_config.ca_certificate), null)
}

# License — vendored copy of the license module from
# ibmcloud_schematics_bigip_next_for_kubernetes_2_3_license.
module "license" {
  source = "./modules/license"

  depends_on = [data.ibm_container_cluster_config.cluster_config]

  providers = {
    ibm        = ibm
    kubernetes = kubernetes
    http       = http
  }

  enabled = true

  use_cos_bucket = var.use_cos_bucket
  jwt_token      = var.jwt_token

  ibmcloud_api_key              = var.ibmcloud_api_key
  ibmcloud_cos_bucket_region    = var.ibmcloud_cos_bucket_region
  ibmcloud_resource_group       = var.ibmcloud_resource_group
  ibmcloud_cos_instance_name    = var.ibmcloud_cos_instance_name
  ibmcloud_resources_cos_bucket = var.ibmcloud_resources_cos_bucket

  utils_namespace              = var.flo_utils_namespace
  f5_cne_subscription_jwt_file = var.f5_cne_subscription_jwt_file
  license_mode                 = var.license_mode
}
