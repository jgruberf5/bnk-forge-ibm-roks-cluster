variable "ibmcloud_api_key" {
  description = "IBM Cloud API key"
  type        = string
  sensitive   = true
}

variable "ibmcloud_cluster_region" {
  description = "IBM Cloud region for cluster resources"
  type        = string
}

variable "ibmcloud_resource_group" {
  description = "IBM Cloud resource group name"
  type        = string
  default     = "default"
}

variable "roks_cluster_name" {
  description = "Name of the IBM ROKS cluster"
  type        = string
}

variable "workers_per_zone" {
  description = "Number of worker nodes per zone"
  type        = number
}

variable "min_worker_vcpu_count" {
  description = "Minimum worker vCPU count"
  type        = number
  default     = 16
}

variable "min_worker_memory_gb" {
  description = "Minimum worker memory in GB"
  type        = number
  default     = 64
}

variable "openshift_cluster_version" {
  description = "OpenShift cluster version"
  type        = string
  default     = "4.18"
}

variable "worker_pool_name" {
  description = "Worker pool name"
  type        = string
  default     = "default"
}
