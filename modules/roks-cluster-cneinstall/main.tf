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

# Look up the existing ROKS cluster — entry point for VPC discovery.
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

# Kubernetes provider wired to the live cluster config. CNEInstance only
# needs the kubernetes provider — no helm releases happen here.
provider "kubernetes" {
  host                   = try(data.ibm_container_cluster_config.cluster_config.host, "")
  token                  = try(data.ibm_container_cluster_config.cluster_config.token, "")
  cluster_ca_certificate = try(base64decode(data.ibm_container_cluster_config.cluster_config.ca_certificate), null)
}

# CNEInstance — vendored copy of the cneinstance module from
# ibmcloud_schematics_bigip_next_for_kubernetes_2_3_cneinstance.
module "cneinstance" {
  source = "./modules/cneinstance"

  depends_on = [data.ibm_container_cluster_config.cluster_config]

  providers = {
    kubernetes = kubernetes
  }

  enabled = true

  flo_namespace                      = var.flo_namespace
  utils_namespace                    = var.flo_utils_namespace
  cluster_issuer_name                = var.flo_cluster_issuer_name
  far_repo_url                       = var.far_repo_url
  f5_bigip_k8s_manifest_version      = var.f5_bigip_k8s_manifest_version
  cneinstance_ibm_trusted_profile_id = var.flo_trusted_profile_id

  cneinstance_gateway_api          = var.cneinstance_gateway_api
  cneinstance_whole_cluster        = var.cneinstance_whole_cluster
  cneinstance_logging_subsystem    = var.cneinstance_logging_subsystem
  cneinstance_metric_subsystem     = var.cneinstance_metric_subsystem
  cneinstance_deployment_size      = var.cneinstance_deployment_size
  cneinstance_dynamic_routing      = var.cneinstance_dynamic_routing
  cneinstance_firewall_acl         = var.cneinstance_firewall_acl
  cneinstance_pseudocni            = var.cneinstance_pseudocni
  cneinstance_env_discovery        = var.cneinstance_env_discovery
  cneinstance_cloud_env            = var.cneinstance_cloud_env
  cneinstance_cloud_provider       = "ibm"
  cneinstance_vpc_name             = data.ibm_is_vpc.cluster_vpc.name
  cneinstance_cloud_region         = var.ibmcloud_cluster_region
  cneinstance_gslb_datacenter_name = var.cneinstance_gslb_datacenter_name
  cneinstance_network_attachments  = var.cneinstance_network_attachments
}
