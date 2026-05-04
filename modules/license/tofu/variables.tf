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
  description = "IBM Cloud resource group used for cluster and COS discovery"
  type        = string
  default     = "default"
}

variable "roks_cluster_name_or_id" {
  description = "Name or ID of the existing IBM ROKS cluster where the License resource will be installed"
  type        = string
}

variable "flo_utils_namespace" {
  description = "Namespace for F5 utility components and the License custom resource"
  type        = string
  default     = "f5-utils"
}

variable "license_mode" {
  description = "License operation mode"
  type        = string
  default     = "connected"
}

variable "use_cos_bucket" {
  description = "Fetch JWT token from IBM Cloud Object Storage"
  type        = bool
  default     = true
}

variable "jwt_token" {
  description = "Direct JWT token for license authentication when COS is not used"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ibmcloud_cos_bucket_region" {
  description = "IBM Cloud region where the COS bucket is located"
  type        = string
  default     = "us-south"
}

variable "ibmcloud_cos_instance_name" {
  description = "IBM Cloud COS instance name"
  type        = string
  default     = "bnk-orchestration"
}

variable "ibmcloud_resources_cos_bucket" {
  description = "COS bucket containing the license JWT file"
  type        = string
  default     = "bnk-schematics-resources"
}

variable "f5_cne_subscription_jwt_file" {
  description = "License JWT filename in the COS bucket"
  type        = string
  default     = "trial.jwt"
}
