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
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
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

# Confirm the target cluster exists before we try to talk to its API.
data "ibm_container_vpc_cluster" "existing_cluster" {
  name              = var.roks_cluster_name_or_id
  resource_group_id = data.ibm_resource_group.resource_group.id
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
  kubernetes {
    host                   = try(data.ibm_container_cluster_config.cluster_config.host, "")
    token                  = try(data.ibm_container_cluster_config.cluster_config.token, "")
    cluster_ca_certificate = try(base64decode(data.ibm_container_cluster_config.cluster_config.ca_certificate), null)
  }
}

# cert-manager namespace.
resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = var.namespace
  }
}

# Install cert-manager via Helm with installCRDs=true and the
# ServerSideApply feature gate (matches the reference cert-manager module
# from ibmcloud_schematics_bigip_next_for_kubernetes_2_3_cert_manager).
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = var.chart_repository
  chart      = "cert-manager"
  namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name
  version    = var.chart_version
  wait       = var.wait_for_deployment
  timeout    = var.timeout

  set = [
    {
      name  = "installCRDs"
      value = "true"
    },
    {
      name  = "featureGates"
      value = "ServerSideApply=true"
    },
  ]

  depends_on = [kubernetes_namespace_v1.cert_manager]
}

# Wait briefly so cert-manager CRDs (ClusterIssuer, Certificate, …) are
# fully registered before any dependent resource tries to use them.
resource "time_sleep" "cert_manager_ready" {
  depends_on      = [helm_release.cert_manager]
  create_duration = "${var.post_deployment_delay}s"
}
