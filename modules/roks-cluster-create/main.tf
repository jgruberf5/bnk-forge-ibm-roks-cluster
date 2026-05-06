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

data "ibm_is_zones" "regional_zones" {
  region = var.ibmcloud_cluster_region
}

data "ibm_container_cluster_versions" "cluster_versions" {}

data "ibm_is_instance_profiles" "cluster_worker_profiles" {}

data "ibm_resource_instance" "registry_cos" {
  name              = var.ibmcloud_cos_instance_name
  location          = "global"
  resource_group_id = data.ibm_resource_group.resource_group.id
  service           = "cloud-object-storage"
}

locals {
  zone_names = length(var.zones) > 0 ? var.zones : slice(data.ibm_is_zones.regional_zones.zones, 0, 3)

  matching_versions = var.openshift_cluster_version != "" ? [
    for version in data.ibm_container_cluster_versions.cluster_versions.valid_openshift_versions :
    version if startswith(version, var.openshift_cluster_version)
  ] : data.ibm_container_cluster_versions.cluster_versions.valid_openshift_versions

  selected_openshift_version = "${reverse(sort(
    length(local.matching_versions) > 0 ? local.matching_versions : data.ibm_container_cluster_versions.cluster_versions.valid_openshift_versions
  ))[0]}_openshift"

  eligible_worker_profiles = [
    for profile in data.ibm_is_instance_profiles.cluster_worker_profiles.profiles :
    {
      name   = profile.name
      vcpu   = profile.vcpu_count[0].value
      memory = profile.memory[0].value
    }
    if profile.vcpu_count[0].value >= var.min_worker_vcpu_count &&
    profile.memory[0].value >= var.min_worker_memory_gb &&
    can(regex("^bx2-[0-9]+x[0-9]+$", profile.name))
  ]

  worker_flavor = var.worker_flavor != "" ? var.worker_flavor : (
    length(local.eligible_worker_profiles) > 0 ? replace(
      [
        for profile in local.eligible_worker_profiles :
        profile.name if profile.vcpu == min([for candidate in local.eligible_worker_profiles : candidate.vcpu]...) &&
        profile.memory == min([
          for candidate in local.eligible_worker_profiles :
          candidate.memory if candidate.vcpu == min([for inner_candidate in local.eligible_worker_profiles : inner_candidate.vcpu]...)
        ]...)
      ][0],
      "-",
      "."
    ) : "bx2.16x64"
  )

  vpc_name = var.cluster_vpc_name != "" ? var.cluster_vpc_name : "${var.roks_cluster_name}-vpc"
}

resource "ibm_is_vpc" "cluster_vpc" {
  name           = local.vpc_name
  resource_group = data.ibm_resource_group.resource_group.id
  tags           = ["bnk-forge", "ibm-roks"]
}

resource "ibm_is_subnet" "cluster_subnets" {
  count                    = 3
  name                     = "${var.roks_cluster_name}-subnet-zone${count.index + 1}"
  vpc                      = ibm_is_vpc.cluster_vpc.id
  zone                     = local.zone_names[count.index]
  total_ipv4_address_count = 256
  ipv4_cidr_block          = cidrsubnet(var.cluster_vpc_cidr, 8, count.index)
  resource_group           = data.ibm_resource_group.resource_group.id
}

resource "ibm_is_public_gateway" "cluster_gateways" {
  count          = 3
  name           = "${var.roks_cluster_name}-gateway-zone${count.index + 1}"
  vpc            = ibm_is_vpc.cluster_vpc.id
  zone           = local.zone_names[count.index]
  resource_group = data.ibm_resource_group.resource_group.id
}

resource "ibm_is_subnet_public_gateway_attachment" "cluster_gateway_attachments" {
  count          = 3
  subnet         = ibm_is_subnet.cluster_subnets[count.index].id
  public_gateway = ibm_is_public_gateway.cluster_gateways[count.index].id
}

resource "ibm_container_vpc_cluster" "openshift_cluster" {
  name                                = var.roks_cluster_name
  vpc_id                              = ibm_is_vpc.cluster_vpc.id
  flavor                              = local.worker_flavor
  worker_count                        = var.workers_per_zone
  kube_version                        = local.selected_openshift_version
  resource_group_id                   = data.ibm_resource_group.resource_group.id
  cos_instance_crn                    = data.ibm_resource_instance.registry_cos.crn
  disable_public_service_endpoint     = false
  disable_outbound_traffic_protection = true

  dynamic "zones" {
    for_each = ibm_is_subnet.cluster_subnets
    content {
      subnet_id = zones.value.id
      name      = zones.value.zone
    }
  }

  timeouts {
    create = "120m"
    delete = "90m"
  }

  depends_on = [ibm_is_subnet_public_gateway_attachment.cluster_gateway_attachments]
}

# Pull the kubeconfig generated by IBM Cloud once the cluster is up.
# ibm_container_cluster_config writes it to disk; local_file reads it
# back so we can expose it as a base64-encoded output for bnk-forge
# auto-registration.
data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id = ibm_container_vpc_cluster.openshift_cluster.id
  region          = var.ibmcloud_cluster_region
  depends_on      = [ibm_container_vpc_cluster.openshift_cluster]
}

data "local_file" "kubeconfig" {
  filename   = data.ibm_container_cluster_config.cluster_config.config_file_path
  depends_on = [data.ibm_container_cluster_config.cluster_config]
}
