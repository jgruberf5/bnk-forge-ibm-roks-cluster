# IBM Cloud credentials — inherited from the project's IBM Cloud
# Credential Template at deploy time.
variable "ibmcloud_api_key" {
  description = "IBM Cloud API key used to fetch cluster credentials and read COS resources."
  type        = string
  sensitive   = true
}

variable "ibmcloud_cluster_region" {
  description = "IBM Cloud region where the existing ROKS cluster resides."
  type        = string
}

variable "ibmcloud_resource_group" {
  description = "IBM Cloud resource group used for cluster discovery and trusted-profile binding."
  type        = string
  default     = "default"
}

# Cluster target.
variable "roks_cluster_name_or_id" {
  description = "Existing IBM ROKS cluster name or ID where FLO will be installed."
  type        = string
}

# cert-manager dependency — set to true when cert-manager has been applied.
variable "cert_manager_crd_ready" {
  description = "Set to true when cert-manager has been applied and its CRDs are registered."
  type        = bool
  default     = true
}

variable "cert_manager_namespace" {
  description = "Namespace where cert-manager is installed."
  type        = string
  default     = "cert-manager"
}

# FAR / registry.
variable "far_repo_url" {
  description = "FAR Repository URL for Docker and Helm registry."
  type        = string
  default     = "repo.f5.com"
}

variable "f5_bigip_k8s_manifest_version" {
  description = "Version of the f5-bigip-k8s-manifest chart (FLO/CIS versions are extracted from this)."
  type        = string
  default     = "2.3.0-3.2598.3-0.0.170"
}

# COS bucket — fetch FAR auth key + JWT from IBM Cloud Object Storage.
variable "use_cos_bucket" {
  description = "Fetch FAR auth key and JWT from IBM Cloud Object Storage instead of local variables."
  type        = bool
  default     = true
}

variable "ibmcloud_cos_bucket_region" {
  description = "IBM Cloud region where the COS bucket is located."
  type        = string
  default     = "us-south"
}

variable "ibmcloud_cos_instance_name" {
  description = "IBM Cloud COS instance name."
  type        = string
  default     = "bnk-orchestration"
}

variable "ibmcloud_resources_cos_bucket" {
  description = "IBM Cloud COS bucket containing the FAR auth key and JWT files."
  type        = string
  default     = "bnk-schematics-resources"
}

variable "f5_cne_far_auth_file" {
  description = "FAR auth key filename in the COS bucket (.tgz)."
  type        = string
  default     = "f5-far-auth-key.tgz"
}

variable "f5_cne_subscription_jwt_file" {
  description = "Subscription JWT filename in the COS bucket."
  type        = string
  default     = "trial.jwt"
}

# FLO namespaces.
variable "flo_namespace" {
  description = "Namespace for F5 Lifecycle Operator."
  type        = string
  default     = "f5-bnk"
}

variable "flo_utils_namespace" {
  description = "Namespace for F5 utility components."
  type        = string
  default     = "f5-utils"
}

# BIG-IP CIS.
variable "bigip_username" {
  description = "BIG-IP username for CIS controller login."
  type        = string
  default     = "admin"
}

variable "bigip_password" {
  description = "BIG-IP password for CIS controller login."
  type        = string
  default     = ""
  sensitive   = true
}

variable "bigip_url" {
  description = "BIG-IP URL for CIS controller login."
  type        = string
  default     = ""
}

# NetworkAttachmentDefinition (NAD) configuration.
variable "nad_cni_type" {
  description = "CNI type for NAD (host-device or ipvlan)."
  type        = string
  default     = "ipvlan"
  validation {
    condition     = contains(["host-device", "ipvlan"], var.nad_cni_type)
    error_message = "CNI type must be either 'host-device' or 'ipvlan'."
  }
}

variable "nad_interface_name" {
  description = "Network interface name for NAD (e.g., ens7, eth1)."
  type        = string
  default     = "ens3"
}

variable "nad_ipvlan_mode" {
  description = "IPVLAN mode (l2 or l3) — only used when nad_cni_type is ipvlan."
  type        = string
  default     = "l2"
  validation {
    condition     = contains(["l2", "l3"], var.nad_ipvlan_mode)
    error_message = "IPVLAN mode must be either 'l2' or 'l3'."
  }
}
