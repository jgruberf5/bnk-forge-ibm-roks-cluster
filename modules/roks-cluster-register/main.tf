terraform {
  required_version = ">= 1.0"

  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.60.0"
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

resource "terraform_data" "registration_marker" {
  input = {
    cluster_id   = data.ibm_container_vpc_cluster.existing_cluster.id
    cluster_name = data.ibm_container_vpc_cluster.existing_cluster.name
  }
}
