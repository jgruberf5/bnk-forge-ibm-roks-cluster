# IBM Cloud credentials — inherited from the project's IBM Cloud
# Credential Template at deploy time.
variable "ibmcloud_api_key" {
  description = "IBM Cloud API key used to fetch cluster credentials."
  type        = string
  sensitive   = true
}

variable "ibmcloud_cluster_region" {
  description = "IBM Cloud region where the existing ROKS cluster resides."
  type        = string
}

variable "ibmcloud_resource_group" {
  description = "IBM Cloud resource group used for cluster discovery."
  type        = string
  default     = "default"
}

# Cluster target.
variable "roks_cluster_name_or_id" {
  description = "Existing IBM ROKS cluster name or ID where CNEInstance will be deployed."
  type        = string
}

# FAR / registry configuration.
variable "far_repo_url" {
  description = "FAR Repository URL for Docker and Helm registry."
  type        = string
  default     = "repo.f5.com"
}

variable "f5_bigip_k8s_manifest_version" {
  description = "Version of the f5-bigip-k8s-manifest chart (CNEInstance pulls images defined here)."
  type        = string
  default     = "2.3.0-3.2598.3-0.0.170"
}

# FLO context — typically piped from the FLO module's outputs through the
# blueprint, but accept defaults so the module is usable standalone.
variable "flo_namespace" {
  description = "Namespace where the F5 Lifecycle Operator is installed."
  type        = string
  default     = "f5-bnk"
}

variable "flo_utils_namespace" {
  description = "Namespace where F5 utility components are installed."
  type        = string
  default     = "f5-utils"
}

variable "flo_cluster_issuer_name" {
  description = "mTLS certificate issuer name produced by the FLO module."
  type        = string
  default     = ""
}

variable "flo_trusted_profile_id" {
  description = "IBM IAM Trusted Profile ID produced by the FLO module."
  type        = string
  default     = ""
}

# CNEInstance configuration.
variable "cneinstance_deployment_size" {
  description = "Deployment size for CNEInstance (Small, Medium, Large)."
  type        = string
  default     = "Small"
}

variable "cneinstance_gslb_datacenter_name" {
  description = "GSLB datacenter name for CNEInstance (optional)."
  type        = string
  default     = ""
}

variable "cneinstance_network_attachments" {
  description = "Multus Network Attachment Definitions for CNEInstance TMM deployments."
  type        = list(string)
  default     = ["ens3-ipvlan-l2", "macvlan-conf"]
}

# CNEInstance feature toggles. Defaults match the reference orchestrator.
variable "cneinstance_gateway_api" {
  description = "Enable Gateway API support in CNEInstance."
  type        = bool
  default     = true
}

variable "cneinstance_whole_cluster" {
  description = "Run CNEInstance against the whole cluster."
  type        = bool
  default     = true
}

variable "cneinstance_logging_subsystem" {
  description = "Enable the CNEInstance logging subsystem."
  type        = bool
  default     = true
}

variable "cneinstance_metric_subsystem" {
  description = "Enable the CNEInstance metric subsystem."
  type        = bool
  default     = true
}

variable "cneinstance_dynamic_routing" {
  description = "Enable CNEInstance dynamic routing."
  type        = bool
  default     = false
}

variable "cneinstance_firewall_acl" {
  description = "Enable CNEInstance firewall ACL."
  type        = bool
  default     = true
}

variable "cneinstance_pseudocni" {
  description = "Enable CNEInstance pseudo-CNI mode."
  type        = bool
  default     = true
}

variable "cneinstance_env_discovery" {
  description = "Enable CNEInstance environment discovery."
  type        = bool
  default     = false
}

variable "cneinstance_cloud_env" {
  description = "Enable CNEInstance cloud-environment integration."
  type        = bool
  default     = true
}
