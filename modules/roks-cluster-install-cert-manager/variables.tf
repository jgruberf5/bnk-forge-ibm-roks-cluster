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
  description = "Existing IBM ROKS cluster name or ID where cert-manager will be installed."
  type        = string
}

# cert-manager configuration (mirrors the reference cert-manager module).
variable "namespace" {
  description = "Kubernetes namespace for cert-manager."
  type        = string
  default     = "cert-manager"
}

variable "chart_version" {
  description = "cert-manager Helm chart version."
  type        = string
  default     = "v1.17.3"
}

variable "chart_repository" {
  description = "Helm chart repository URL."
  type        = string
  default     = "https://charts.jetstack.io"
}

variable "wait_for_deployment" {
  description = "Wait for cert-manager pods to become ready before returning."
  type        = bool
  default     = true
}

variable "timeout" {
  description = "Timeout (seconds) for the cert-manager Helm release."
  type        = number
  default     = 300
}

variable "post_deployment_delay" {
  description = "Delay (seconds) after the Helm release to let CRDs register before downstream modules use them."
  type        = number
  default     = 30
}
