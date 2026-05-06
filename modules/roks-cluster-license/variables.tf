# IBM Cloud credentials — inherited from the project's IBM Cloud
# Credential Template at deploy time.
variable "ibmcloud_api_key" {
  description = "IBM Cloud API key used to fetch cluster credentials and read the JWT from COS."
  type        = string
  sensitive   = true
}

variable "ibmcloud_cluster_region" {
  description = "IBM Cloud region where the existing ROKS cluster resides."
  type        = string
}

variable "ibmcloud_resource_group" {
  description = "IBM Cloud resource group used for cluster discovery and COS lookup."
  type        = string
  default     = "default"
}

# Cluster target.
variable "roks_cluster_name_or_id" {
  description = "Existing IBM ROKS cluster name or ID where the License CR will be deployed."
  type        = string
}

# COS bucket — fetch JWT from IBM Cloud Object Storage.
variable "use_cos_bucket" {
  description = "Fetch the F5 subscription JWT from an IBM Cloud Object Storage bucket."
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
  description = "IBM Cloud COS bucket containing the F5 subscription JWT."
  type        = string
  default     = "bnk-schematics-resources"
}

variable "f5_cne_subscription_jwt_file" {
  description = "Subscription JWT filename in the COS bucket."
  type        = string
  default     = "trial.jwt"
}

# Direct JWT — only used when use_cos_bucket = false.
variable "jwt_token" {
  description = "F5 subscription JWT token (used when use_cos_bucket = false)."
  type        = string
  sensitive   = true
  default     = ""
}

# License configuration.
variable "license_mode" {
  description = "License operation mode (connected or disconnected)."
  type        = string
  default     = "connected"

  validation {
    condition     = contains(["connected", "disconnected"], var.license_mode)
    error_message = "license_mode must be either 'connected' or 'disconnected'."
  }
}

# FLO context — typically piped from the FLO module via the blueprint.
variable "flo_utils_namespace" {
  description = "Namespace where F5 utility components are installed (License CR is created here)."
  type        = string
  default     = "f5-utils"
}
