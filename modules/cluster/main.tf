terraform {
  required_version = ">= 1.0"

  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.60.0"
    }
  }
}

locals {
  cos_instance_name    = "${var.roks_cluster_name}-registry-cos"
  transit_gateway_name = "${var.roks_cluster_name}-tgw"
  cluster_vpc_name     = "${var.roks_cluster_name}-vpc"
}

module "cluster" {
  source = "git::https://github.com/f5devcentral/ibmcloud_schematics_bigip_next_for_kubernetes_roks_cluster_4.git//modules/cluster?ref=main"

  ibmcloud_api_key          = var.ibmcloud_api_key
  cluster_region            = var.ibmcloud_cluster_region
  resource_group            = var.ibmcloud_resource_group
  create_cluster            = true
  create_client_vpc         = false
  create_jumphost           = false
  create_transit_gateway    = true
  create_cos_instance       = true
  cluster_vpc_name          = local.cluster_vpc_name
  use_existing_cluster_vpc  = false
  existing_cluster_vpc_id   = ""
  zones                     = []
  client_vpc_name           = ""
  client_vpc_region         = var.ibmcloud_cluster_region
  use_existing_client_vpc   = false
  existing_client_vpc_id    = ""
  client_jumphost_name      = ""
  ssh_key_name              = ""
  jumphost_profile          = ""
  min_vcpu_count            = 4
  min_memory_gb             = 8
  openshift_cluster_name    = var.roks_cluster_name
  openshift_cluster_version = var.openshift_cluster_version
  worker_pool_name          = var.worker_pool_name
  worker_flavor             = ""
  min_worker_vcpu_count     = var.min_worker_vcpu_count
  min_worker_memory_gb      = var.min_worker_memory_gb
  workers_per_zone          = var.workers_per_zone
  cos_instance_name         = local.cos_instance_name
  transit_gateway_name      = local.transit_gateway_name
}
