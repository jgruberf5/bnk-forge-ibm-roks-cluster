variable "ibmcloud_api_key" {
  description = "IBM Cloud API key"
  type        = string
  sensitive   = true
}

variable "ibmcloud_cluster_region" {
  description = "IBM Cloud region where the existing ROKS cluster resides"
  type        = string
}

variable "ibmcloud_resource_group" {
  description = "IBM Cloud resource group used to discover the existing cluster"
  type        = string
  default     = "default"
}

variable "roks_cluster_name_or_id" {
  description = "Existing IBM ROKS cluster name or ID"
  type        = string
}
