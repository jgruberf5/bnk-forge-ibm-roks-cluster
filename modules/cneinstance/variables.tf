variable "ibmcloud_api_key" {
  description = "IBM Cloud API key"
  type        = string
  sensitive   = true
}

variable "ibmcloud_cluster_region" {
  description = "IBM Cloud region where the existing cluster resides"
  type        = string
}

variable "ibmcloud_resource_group" {
  description = "IBM Cloud resource group used for cluster discovery"
  type        = string
  default     = "default"
}

variable "roks_cluster_name_or_id" {
  description = "Name or ID of the existing IBM ROKS cluster where CNEInstance will be installed"
  type        = string
}

variable "flo_namespace" {
  description = "Namespace where FLO is already installed"
  type        = string
  default     = "f5-bnk"
}

variable "flo_utils_namespace" {
  description = "Namespace for F5 utility components"
  type        = string
  default     = "f5-utils"
}

variable "f5_bigip_k8s_manifest_version" {
  description = "Version of the f5-bigip-k8s-manifest chart used by the upstream CNEInstance module"
  type        = string
  default     = "2.3.0-bnpp-ehf-2-3.2598.3-0.0.17"
}

variable "far_repo_url" {
  description = "FAR repository URL"
  type        = string
  default     = "repo.f5.com"
}

variable "flo_trusted_profile_id" {
  description = "IBM IAM trusted profile ID created by FLO"
  type        = string
  default     = ""
}

variable "flo_cluster_issuer_name" {
  description = "Cluster issuer name created by FLO"
  type        = string
  default     = ""
}

variable "cneinstance_deployment_size" {
  description = "Deployment size for CNEInstance"
  type        = string
  default     = "Small"
}

variable "cneinstance_gslb_datacenter_name" {
  description = "Optional GSLB datacenter name for CNEInstance"
  type        = string
  default     = ""
}

variable "cneinstance_network_attachments" {
  description = "Multus Network Attachment Definitions for the single-NIC CNEInstance deployment"
  type        = list(string)
  default     = ["ens3-ipvlan-l2", "macvlan-conf"]
}
