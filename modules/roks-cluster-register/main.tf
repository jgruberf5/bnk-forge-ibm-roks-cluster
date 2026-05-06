terraform {
  required_version = ">= 1.0"

  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.60.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0"
    }
  }
}

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

data "ibm_container_vpc_cluster" "existing_cluster" {
  name              = var.roks_cluster_name_or_id
  resource_group_id = data.ibm_resource_group.resource_group.id
}

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id = var.roks_cluster_name_or_id
  region          = var.ibmcloud_cluster_region
}

# ibm_container_cluster_config writes the kubeconfig to disk during apply;
# read it back here so we can expose it as a base64-encoded output for
# bnk-forge auto-registration.
data "local_file" "kubeconfig" {
  filename   = data.ibm_container_cluster_config.cluster_config.config_file_path
  depends_on = [data.ibm_container_cluster_config.cluster_config]
}

resource "terraform_data" "registration_marker" {
  input = {
    cluster_id   = data.ibm_container_vpc_cluster.existing_cluster.id
    cluster_name = data.ibm_container_vpc_cluster.existing_cluster.name
  }
}
