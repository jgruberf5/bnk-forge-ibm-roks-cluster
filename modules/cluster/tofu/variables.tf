variable "ibmcloud_api_key" {
  description = "IBM Cloud API key"
  type        = string
  sensitive   = true
}

variable "ibmcloud_cluster_region" {
  description = "BNK-facing IBM Cloud region input mapped to the upstream cluster_region variable"
  type        = string
}

variable "ibmcloud_resource_group" {
  description = "BNK-facing IBM Cloud resource group input mapped to the upstream resource_group variable"
  type        = string
  default     = "default"
}

variable "roks_cluster_name" {
  description = "BNK-facing cluster name mapped to the upstream openshift_cluster_name variable"
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
  description = "OpenShift major.minor version passed through to the upstream module"
  type        = string
  default     = "4.18"
}

variable "worker_pool_name" {
  description = "Worker pool name passed through to the upstream module"
  type        = string
  default     = "tf-worker-pool"
}
