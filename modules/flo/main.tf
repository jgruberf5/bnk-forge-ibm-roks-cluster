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

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.ibmcloud_cluster_region
}

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id = var.roks_cluster_name_or_id
  region          = var.ibmcloud_cluster_region
}

provider "kubernetes" {
  host                   = try(data.ibm_container_cluster_config.cluster_config.host, "")
  token                  = try(data.ibm_container_cluster_config.cluster_config.token, "")
  cluster_ca_certificate = try(base64decode(data.ibm_container_cluster_config.cluster_config.ca_certificate), null)
}

provider "helm" {
  kubernetes {
    host                   = try(data.ibm_container_cluster_config.cluster_config.host, "")
    token                  = try(data.ibm_container_cluster_config.cluster_config.token, "")
    cluster_ca_certificate = try(base64decode(data.ibm_container_cluster_config.cluster_config.ca_certificate), null)
  }
}

data "ibm_resource_groups" "all" {}

data "ibm_resource_group" "resource_group" {
  name = var.ibmcloud_resource_group != "" ? var.ibmcloud_resource_group : [
    for rg in data.ibm_resource_groups.all.resource_groups :
    rg.name if rg.is_default == true
  ][0]
}

data "ibm_container_vpc_cluster" "cluster" {
  name              = var.roks_cluster_name_or_id
  resource_group_id = data.ibm_resource_group.resource_group.id
}

data "ibm_is_subnet" "cluster_subnet" {
  identifier = data.ibm_container_vpc_cluster.cluster.worker_pools[0].zones[0].subnets[0].id
}

data "ibm_is_vpc" "cluster_vpc" {
  identifier = data.ibm_is_subnet.cluster_subnet.vpc
}

module "flo" {
  source = "git::https://github.com/f5devcentral/ibmcloud_schematics_bigip_next_for_kubernetes_2_3_flo.git//modules/flo?ref=main"

  providers = {
    ibm        = ibm
    kubernetes = kubernetes
    helm       = helm
  }

  enabled                        = true
  cert_manager_crd_ready         = true
  ibmcloud_api_key               = var.ibmcloud_api_key
  ibmcloud_resource_group        = var.ibmcloud_resource_group
  far_repo_url                   = var.far_repo_url
  f5_bigip_k8s_manifest_version  = var.f5_bigip_k8s_manifest_version
  use_cos_bucket                 = var.use_cos_bucket
  ibmcloud_cos_bucket_region     = var.ibmcloud_cos_bucket_region
  ibmcloud_cos_instance_name     = var.ibmcloud_cos_instance_name
  ibmcloud_resources_cos_bucket  = var.ibmcloud_resources_cos_bucket
  f5_cne_far_auth_file           = var.f5_cne_far_auth_file
  f5_cne_subscription_jwt_file   = var.f5_cne_subscription_jwt_file
  cert_manager_namespace         = var.cert_manager_namespace
  flo_namespace                  = var.flo_namespace
  utils_namespace                = var.flo_utils_namespace
  bigip_username                 = var.bigip_username
  bigip_password                 = var.bigip_password
  bigip_url                      = var.bigip_url
  kube_host                      = data.ibm_container_cluster_config.cluster_config.host
  kube_token                     = data.ibm_container_cluster_config.cluster_config.token
  openshift_cluster_name         = data.ibm_container_vpc_cluster.cluster.name
  openshift_cluster_crn          = data.ibm_container_vpc_cluster.cluster.crn
  cluster_vpc_id                 = data.ibm_is_vpc.cluster_vpc.id
  nad_cni_type                   = "ipvlan"
  nad_interface_name             = "ens3"
  nad_ipvlan_mode                = "l2"
}
